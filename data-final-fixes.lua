-- add placeholder layer for wooden-platform rework
if not data.raw["collision-layer"]["wooden-platform"] then
	data:extend({
		{
			type = "collision-layer",
			name = "wooden-platform",
		},
	})
end

local t = data.raw.tile["wooden-platform"]
if t then
	if not t.collision_mask then
		t.collision_mask = { layers = {} }
	elseif not t.collision_mask.layers then
		t.collision_mask = { layers = t.collision_mask }
	end
	t.collision_mask.layers["wooden-platform"] = true
end

local MASK = "wooden-platform"

local defaults = data.raw["utility-constants"]
	and data.raw["utility-constants"].default
	and data.raw["utility-constants"].default.default_collision_masks

if not defaults then
	error("wooden-platform: missing utility-constants.default.default_collision_masks")
end

local place_result_entities = {}
for _, set in pairs(data.raw) do
	for _, p in pairs(set) do
		local pr = p.place_result
		if pr then
			local name = (type(pr) == "table" and pr.name) or pr
			if type(name) == "string" and name ~= "" then
				place_result_entities[name] = true
			end
		end
	end
end

local circuit_place_results = {}
for _, set in pairs(data.raw) do
	for _, p in pairs(set) do
		if p.subgroup == "circuit-network" and p.place_result then
			local pr = p.place_result
			local name = (type(pr) == "table" and pr.name) or pr
			if type(name) == "string" and name ~= "" then
				circuit_place_results[name] = true
			end
		end
	end
end
local function is_1x1_container(proto_type, prototype)
	if proto_type ~= "container" and proto_type ~= "logistic-container" then
		return false
	end

	local box = prototype.collision_box or prototype.selection_box
	if not box or not box[1] or not box[2] then
		return false
	end

	local a, b = box[1], box[2]
	local ax = a.x or a[1]
	local ay = a.y or a[2]
	local bx = b.x or b[1]
	local by = b.y or b[2]
	if not (ax and ay and bx and by) then
		return false
	end

	local w = math.abs(bx - ax)
	local h = math.abs(by - ay)

	return w <= 1.2 and h <= 1.2
end

local function apply_platform_mask(proto_type, prototype)
	local whitelisted_basic = (proto_type == "inserter")
		or (proto_type == "transport-belt")
		or (proto_type == "car")
		or (proto_type == "locomotive")
		or (proto_type == "fluid-wagon")
		or (proto_type == "cargo-wagon")
		or (proto_type == "radar")
		or (proto_type == "pipe")
		or (proto_type == "ammo-turret")
		or (proto_type == "fluid-turret")
		--or prototype.name == "gun-turret"
		--or prototype.name == "heavy-gun-turret"
		--or prototype.name == "flamethrower-turret"
		--or prototype.name == "rocket-turret"
		or prototype.name == "barreling-machine"
		or prototype.name == "canex-excavator"
		or prototype.name == "entity-ghost"
		or prototype.name == "pump"
		or prototype.name == "long-range-delivery-drone-request-depot"
		or prototype.name == "oil_rig"
		or prototype.name == "or_power_electric"
		or prototype.name == "or_pole"
		or prototype.name == "or_radar"
		or prototype.name == "or_tank"
		or prototype.name == "kr-steel-pump"

	if not whitelisted_basic and not place_result_entities[prototype.name] then
		return
	end

	local layers
	local using_default = false

	if prototype.collision_mask then
		if prototype.collision_mask.layers then
			layers = prototype.collision_mask.layers
		elseif type(prototype.collision_mask) == "table" then
			prototype.collision_mask = { layers = prototype.collision_mask }
			layers = prototype.collision_mask.layers
		end
	else
		local d = defaults[proto_type]
		if d and d.layers then
			layers = d.layers
			using_default = true
		end
	end

	if not (layers and (layers["is_object"] or layers["is_lower_object"] or layers["object"])) then
		return
	end

	local whitelisted = whitelisted_basic
		or circuit_place_results[prototype.name]
		or is_1x1_container(proto_type, prototype)

	if using_default and whitelisted then
		prototype.collision_mask = { layers = table.deepcopy(layers) }
		layers = prototype.collision_mask.layers
		using_default = false
	end

	if whitelisted then
		layers[MASK] = nil
	else
		layers[MASK] = true
	end
end

for proto_type, set in pairs(data.raw) do
	for _, prototype in pairs(set) do
		apply_platform_mask(proto_type, prototype)
	end
end

--log("wooden-platform DEBUG: listing place_result entities")
--
--local count = 0
--for name, _ in pairs(place_result_entities) do
--	log("  place_result -> " .. name)
--	count = count + 1
--end

--log("wooden-platform DEBUG: total place_result entities = " .. count)
--log("wooden-platform: applied via single function (custom/default + whitelist + place_result filter)")
