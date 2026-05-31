if mods["pelagos"] then
	data:extend({
		{
			type = "recipe",
			name = "pelagos-wooden-platform",
			icons = {
				{ icon = "__wooden_platform__/graphics/wooden-platform-icon.png", icon_size = 64 },
				{ icon = "__pelagos__/graphics/sealant.png", icon_size = 64, scale = 0.25, shift = { 8, 8 } },
			},
			enabled = false,
			ingredients = {
				{ type = "item", name = "wood", amount = 15 },
				{ type = "item", name = "coconut-sealant", amount = 5 },
				{ type = "item", name = "coconut-husk", amount = 10 },
			},
			results = { { type = "item", name = "wooden-platform", amount = 1 } },
			auto_recycle = false,
		},
	})
	table.insert(
		data.raw["technology"]["coconut-processing-technology"].effects,
		{ type = "unlock-recipe", recipe = "pelagos-wooden-platform" }
	)

	local item = data.raw.item["wooden-platform"]
	table.insert(item.place_as_tile.tile_condition, "pelagos-deepsea")
	item.default_import_location = "pelagos"
	data.raw["recipe"]["wooden-platform"].enabled = false
end

-- arig compatibility
if mods["planetaris-arig"] then
	local item = data.raw.item["wooden-platform"]
	if item and item.place_as_tile and data.raw.tile["arig-sand"] then
		table.insert(item.place_as_tile.tile_condition, "arig-sand")
		table.insert(item.place_as_tile.tile_condition, "arig-deep-sand")
	end
end
