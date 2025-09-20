#!/usr/bin/env lua

print("🚀 Cosmo Terrain Generator Test Suite")
print("=====================================\n")

local test_files = {
    "test/test_helpers_test.lua",
    "test/test_generators.lua"
}

local total_passed = true

for _, test_file in ipairs(test_files) do
    print("📁 Running: " .. test_file)
    local result = os.execute("lua " .. test_file)

    if result ~= 0 then
        total_passed = false
        print("❌ Test file failed: " .. test_file)
    else
        print("✅ Test file passed: " .. test_file)
    end
    print()
end

print("\n🏁 Final Result:")
if total_passed then
    print("🎉 All test suites passed!")
    os.exit(0)
else
    print("💥 Some tests failed!")
    os.exit(1)
end