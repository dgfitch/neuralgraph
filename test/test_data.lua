require 'data'
require 'love_stubs'
require 'main'
require 'lunity'
module( 'TEST_DATA', lunity )


function prepareObjects()
  table.clear(objects.collection)
end

function test_001_Serialize_String()
  assertEqual( data.serialize("a"), "\"a\"" )
end

function test_002_Serialize_Integer()
  assertEqual( data.serialize(1), "1" )
end

function test_003_Serialize_Float()
  assertEqual( data.serialize(1.01), "1.01" )
end

function test_004_Serialize_SimpleTable()
  local t = {
    a = "yo",
    b = 2,
  }
  assertEqual( data.serialize(t), "{\n a = \"yo\",\n b = 2,\n}\n" )
end

function test_005_Serialize_NestedTable()
  local t = {
    a = "yo",
    b = {
      x = 1,
      y = 2,
    },
  }
  assertEqual( data.serialize(t), "{\n a = \"yo\",\n b = {\n y = 2,\n x = 1,\n}\n,\n}\n" )
end
runTests { useANSI = true }
