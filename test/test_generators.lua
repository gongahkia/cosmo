package.path = "./src/?.lua;" .. package.path

local TestFramework = require("test.test_framework")
local TestHelpers = require("test.test_helpers")

TestHelpers.mock_love_math()

local test = TestFramework.new()

local function test_generator_basic_properties(generator_name, generator_module)
    test.describe(generator_name .. " Generator", function(t)
        t.it("should exist and be a table", function()
            t.assert_type(generator_module, "table")
        end)

        t.it("should have a generate function", function()
            t.assert_type(generator_module.generate, "function")
        end)

        t.it("should generate terrain with correct dimensions", function()
            local width, height = 20, 15
            local terrain = generator_module.generate(width, height)

            t.assert_not_nil(terrain)
            t.assert_type(terrain, "table")

            local valid, error_msg = TestHelpers.validate_terrain_bounds(terrain, width, height)
            t.assert_true(valid, error_msg)
        end)

        t.it("should generate terrain with valid characters", function()
            local terrain = generator_module.generate(30, 20)
            local valid, error_msg = TestHelpers.validate_terrain_characters(terrain)
            t.assert_true(valid, error_msg)
        end)

        t.it("should generate different terrain on multiple calls", function()
            local terrain1 = generator_module.generate(10, 10)
            local terrain2 = generator_module.generate(10, 10)

            local different = false
            for y = 1, 10 do
                for x = 1, 10 do
                    if terrain1[y][x] ~= terrain2[y][x] then
                        different = true
                        break
                    end
                end
                if different then break end
            end

            t.assert_true(different, "Terrain should vary between generations")
        end)

        t.it("should have reasonable terrain diversity", function()
            local terrain = generator_module.generate(50, 40)
            local diversity = TestHelpers.get_terrain_diversity(terrain)
            t.assert_true(diversity >= 2, "Should have at least 2 different terrain types")
        end)
    end)
end

local generators_to_test = {
    mountain = require("generator.mountain"),
    forest = require("generator.forest"),
    canyon = require("generator.canyon"),
    archipelago = require("generator.archipelago"),
    badlands = require("generator.badlands")
}

for name, module in pairs(generators_to_test) do
    test_generator_basic_properties(name, module)
end

test.describe("Mountain Generator Specific Tests", function(t)
    local mountain = generators_to_test.mountain

    t.it("should generate mountainous terrain with peaks", function()
        local terrain = mountain.generate(60, 40)
        local counts = TestHelpers.count_terrain_types(terrain)

        t.assert_true((counts['M'] or 0) > 0, "Should have mountain terrain")
        t.assert_true((counts['A'] or 0) > 0, "Should have snow-capped peaks")
    end)

    t.it("should have elevation gradient from low to high", function()
        local terrain = mountain.generate(40, 30)
        local counts = TestHelpers.count_terrain_types(terrain)

        local elevation_chars = {'G', 'F', 'T', 'X', 'R', 'M', 'A'}
        local found_levels = 0

        for _, char in ipairs(elevation_chars) do
            if counts[char] and counts[char] > 0 then
                found_levels = found_levels + 1
            end
        end

        t.assert_true(found_levels >= 3, "Should have multiple elevation levels")
    end)
end)

test.describe("Forest Generator Specific Tests", function(t)
    local forest = generators_to_test.forest

    t.it("should generate forest terrain with trees", function()
        local terrain = forest.generate(50, 40)
        local counts = TestHelpers.count_terrain_types(terrain)

        t.assert_true((counts['F'] or 0) > 0, "Should have forest terrain")
        t.assert_true((counts['T'] or 0) > 0, "Should have tree terrain")
    end)

    t.it("should have water features (rivers)", function()
        local terrain = forest.generate(60, 50)
        local counts = TestHelpers.count_terrain_types(terrain)

        t.assert_true((counts['W'] or 0) > 0, "Should have water features")
    end)

    t.it("should have clearings (grass areas)", function()
        local terrain = forest.generate(50, 40)
        local counts = TestHelpers.count_terrain_types(terrain)

        t.assert_true((counts['G'] or 0) > 0, "Should have grass clearings")
    end)
end)

test.describe("Canyon Generator Specific Tests", function(t)
    local canyon = generators_to_test.canyon

    t.it("should generate canyon terrain with water at bottom", function()
        local terrain = canyon.generate(50, 40)
        local counts = TestHelpers.count_terrain_types(terrain)

        t.assert_true((counts['W'] or 0) > 0, "Should have water in canyon bottom")
        t.assert_true((counts['R'] or 0) > 0, "Should have rocky walls")
    end)

    t.it("should have varied elevation terrain", function()
        local terrain = canyon.generate(60, 40)
        local counts = TestHelpers.count_terrain_types(terrain)

        local terrain_types = 0
        for _ in pairs(counts) do
            terrain_types = terrain_types + 1
        end

        t.assert_true(terrain_types >= 4, "Should have diverse terrain types")
    end)
end)

test.describe("Archipelago Generator Specific Tests", function(t)
    local archipelago = generators_to_test.archipelago

    t.it("should generate islands surrounded by water", function()
        local terrain = archipelago.generate(60, 50)
        local counts = TestHelpers.count_terrain_types(terrain)

        t.assert_true((counts['B'] or 0) > 0, "Should have deep water")
        t.assert_true((counts['W'] or 0) > 0, "Should have shallow water")
        t.assert_true((counts['S'] or 0) > 0 or (counts['O'] or 0) > 0, "Should have beaches")
    end)

    t.it("should have multiple separate land masses", function()
        local terrain = archipelago.generate(80, 60)

        local land_chars = {'M', 'R', 'F', 'O', 'S'}
        local max_groups = 0

        for _, char in ipairs(land_chars) do
            local groups = TestHelpers.check_terrain_connectivity(terrain, char)
            max_groups = math.max(max_groups, groups)
        end

        t.assert_true(max_groups >= 2, "Should have multiple separate islands")
    end)
end)

test.describe("Badlands Generator Specific Tests", function(t)
    local badlands = generators_to_test.badlands

    t.it("should generate badlands terrain with mesas", function()
        local terrain = badlands.generate(60, 50)
        local counts = TestHelpers.count_terrain_types(terrain)

        t.assert_true((counts['R'] or 0) > 0, "Should have rocky terrain")
        t.assert_true((counts['K'] or 0) > 0, "Should have clay terrain")
        t.assert_true((counts['O'] or 0) > 0, "Should have orange sand")
    end)

    t.it("should have arid terrain characteristics", function()
        local terrain = badlands.generate(50, 40)
        local counts = TestHelpers.count_terrain_types(terrain)

        local water_percentage = TestHelpers.calculate_terrain_percentage(terrain, 'W')
        t.assert_true(water_percentage < 20, "Should have limited water features")

        local arid_chars = {'D', 'S', 'O', 'X', 'K'}
        local arid_count = 0
        for _, char in ipairs(arid_chars) do
            arid_count = arid_count + (counts[char] or 0)
        end

        local total = 0
        for _, count in pairs(counts) do
            total = total + count
        end

        local arid_percentage = (arid_count / total) * 100
        t.assert_true(arid_percentage > 30, "Should be predominantly arid terrain")
    end)
end)

test.describe("Cross-Generator Consistency Tests", function(t)
    t.it("all generators should handle edge case dimensions", function()
        for name, generator in pairs(generators_to_test) do
            local small_terrain = generator.generate(3, 3)
            local valid = TestHelpers.validate_terrain_bounds(small_terrain, 3, 3)
            t.assert_true(valid, name .. " should handle small dimensions")

            local large_terrain = generator.generate(100, 80)
            valid = TestHelpers.validate_terrain_bounds(large_terrain, 100, 80)
            t.assert_true(valid, name .. " should handle large dimensions")
        end
    end)

    t.it("all generators should produce deterministic results with same seed", function()
        for name, generator in pairs(generators_to_test) do
            math.randomseed(42)
            local terrain1 = generator.generate(20, 15)

            math.randomseed(42)
            local terrain2 = generator.generate(20, 15)

            local identical = true
            for y = 1, 15 do
                for x = 1, 20 do
                    if terrain1[y][x] ~= terrain2[y][x] then
                        identical = false
                        break
                    end
                end
                if not identical then break end
            end

            t.assert_true(identical, name .. " should be deterministic with same seed")
        end
    end)
end)

local success = test.summary()
os.exit(success and 0 or 1)