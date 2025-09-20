package.path = "./src/?.lua;" .. package.path

local TestFramework = require("test.test_framework")
local TestHelpers = require("test.test_helpers")

local test = TestFramework.new()

test.describe("Test Helpers", function(t)
    t.it("should count terrain types correctly", function()
        local terrain = {
            {'G', 'G', 'W'},
            {'R', 'G', 'W'},
            {'R', 'R', 'S'}
        }

        local counts = TestHelpers.count_terrain_types(terrain)

        t.assert_equals(counts['G'], 3)
        t.assert_equals(counts['W'], 2)
        t.assert_equals(counts['R'], 3)
        t.assert_equals(counts['S'], 1)
    end)

    t.it("should calculate terrain diversity correctly", function()
        local terrain = {
            {'G', 'G', 'W'},
            {'R', 'G', 'W'}
        }

        local diversity = TestHelpers.get_terrain_diversity(terrain)
        t.assert_equals(diversity, 3)
    end)

    t.it("should validate terrain bounds correctly", function()
        local valid_terrain = {
            {'G', 'W', 'R'},
            {'S', 'D', 'F'}
        }

        local valid, error_msg = TestHelpers.validate_terrain_bounds(valid_terrain, 3, 2)
        t.assert_true(valid)

        local invalid_terrain = {
            {'G', 'W'},
            {'S', 'D', 'F'}
        }

        valid, error_msg = TestHelpers.validate_terrain_bounds(invalid_terrain, 3, 2)
        t.assert_false(valid)
        t.assert_not_nil(error_msg)
    end)

    t.it("should validate terrain characters correctly", function()
        local valid_terrain = {
            {'G', 'W', 'R'},
            {'S', 'D', 'F'}
        }

        local valid, error_msg = TestHelpers.validate_terrain_characters(valid_terrain)
        t.assert_true(valid)

        local invalid_terrain = {
            {'G', 'W', 'Z'},
            {'S', '!', 'F'}
        }

        valid, error_msg = TestHelpers.validate_terrain_characters(invalid_terrain)
        t.assert_false(valid)
        t.assert_not_nil(error_msg)
    end)

    t.it("should calculate terrain percentage correctly", function()
        local terrain = {
            {'G', 'G', 'W', 'W'},
            {'G', 'R', 'W', 'S'}
        }

        local grass_percentage = TestHelpers.calculate_terrain_percentage(terrain, 'G')
        t.assert_equals(grass_percentage, 37.5)

        local water_percentage = TestHelpers.calculate_terrain_percentage(terrain, 'W')
        t.assert_equals(water_percentage, 37.5)

        local rock_percentage = TestHelpers.calculate_terrain_percentage(terrain, 'R')
        t.assert_equals(rock_percentage, 12.5)
    end)

    t.it("should check terrain connectivity correctly", function()
        local terrain = {
            {'G', 'G', 'W', 'G'},
            {'R', 'G', 'W', 'G'},
            {'R', 'R', 'W', 'W'},
            {'G', 'G', 'G', 'W'}
        }

        local grass_groups = TestHelpers.check_terrain_connectivity(terrain, 'G')
        t.assert_equals(grass_groups, 3)

        local water_groups = TestHelpers.check_terrain_connectivity(terrain, 'W')
        t.assert_equals(water_groups, 1)

        local rock_groups = TestHelpers.check_terrain_connectivity(terrain, 'R')
        t.assert_equals(rock_groups, 1)
    end)
end)

test.describe("Mock Love Math", function(t)
    t.it("should create love.math.noise function", function()
        TestHelpers.mock_love_math()

        t.assert_not_nil(love)
        t.assert_not_nil(love.math)
        t.assert_type(love.math.noise, "function")
    end)

    t.it("should produce deterministic noise", function()
        TestHelpers.mock_love_math()

        local value1 = love.math.noise(1.5, 2.3)
        local value2 = love.math.noise(1.5, 2.3)

        t.assert_equals(value1, value2)
    end)

    t.it("should produce noise values between 0 and 1", function()
        TestHelpers.mock_love_math()

        for i = 1, 10 do
            local value = love.math.noise(i * 0.1, i * 0.2)
            t.assert_in_range(value, 0, 1)
        end
    end)
end)

local success = test.summary()
os.exit(success and 0 or 1)