local TestFramework = {}

function TestFramework.new()
    local self = {
        tests = {},
        passed = 0,
        failed = 0,
        total = 0
    }

    function self.describe(name, test_func)
        print("\n🧪 Testing: " .. name)
        print(string.rep("-", 50))
        test_func(self)
    end

    function self.it(description, test_func)
        self.total = self.total + 1
        local success, error_msg = pcall(test_func)

        if success then
            self.passed = self.passed + 1
            print("  ✅ " .. description)
        else
            self.failed = self.failed + 1
            print("  ❌ " .. description)
            print("     Error: " .. tostring(error_msg))
        end
    end

    function self.assert_equals(actual, expected, message)
        if actual ~= expected then
            local msg = message or string.format("Expected %s but got %s", tostring(expected), tostring(actual))
            error(msg)
        end
    end

    function self.assert_true(condition, message)
        if not condition then
            error(message or "Expected condition to be true")
        end
    end

    function self.assert_false(condition, message)
        if condition then
            error(message or "Expected condition to be false")
        end
    end

    function self.assert_not_nil(value, message)
        if value == nil then
            error(message or "Expected value to not be nil")
        end
    end

    function self.assert_type(value, expected_type, message)
        local actual_type = type(value)
        if actual_type ~= expected_type then
            local msg = message or string.format("Expected type %s but got %s", expected_type, actual_type)
            error(msg)
        end
    end

    function self.assert_in_range(value, min_val, max_val, message)
        if value < min_val or value > max_val then
            local msg = message or string.format("Expected value %s to be between %s and %s",
                tostring(value), tostring(min_val), tostring(max_val))
            error(msg)
        end
    end

    function self.assert_contains(table_val, expected_value, message)
        for _, v in pairs(table_val) do
            if v == expected_value then
                return
            end
        end
        local msg = message or string.format("Expected table to contain %s", tostring(expected_value))
        error(msg)
    end

    function self.summary()
        print("\n" .. string.rep("=", 50))
        print("📊 Test Summary:")
        print(string.format("  Total tests: %d", self.total))
        print(string.format("  Passed: %d", self.passed))
        print(string.format("  Failed: %d", self.failed))

        if self.failed == 0 then
            print("🎉 All tests passed!")
        else
            print(string.format("⚠️  %d test(s) failed", self.failed))
        end
        print(string.rep("=", 50))

        return self.failed == 0
    end

    return self
end

return TestFramework