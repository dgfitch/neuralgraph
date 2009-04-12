require 'data'
require 'test_mocks'
require 'main'
require 'lunity'
module( 'TEST_DATA', lunity )


function prepareObjects()
  objects.collection = {}
end

function test_001_Serialize_String()
  assertEqual( data.serialize{object="a"}, "\"a\"" )
end

function test_002_Serialize_Integer()
  assertEqual( data.serialize{object=1}, "1" )
end

function test_003_Serialize_Float()
  assertEqual( data.serialize{object=1.01}, "1.01" )
end

function test_004_Serialize_SimpleTable()
  local t = {
    a = "yo",
    b = 2,
  }
  assertEqual( data.serialize{object=t}, "{\n  a = \"yo\",\n  b = 2,\n}\n" )
end

function test_005_Serialize_NestedTable()
  local t = {
    a = "yo",
    b = {
      x = 1,
      y = 2,
    },
  }
  assertEqual( data.serialize{object=t}, "{\n  a = \"yo\",\n  b = {\n    y = 2,\n    x = 1,\n  }\n,\n}\n" )
end

function test_006_Serialize_SingleNode()
  prepareObjects()
  local node = objects.node.getNew(1,2)
  table.insert(objects.collection,node)
  assertEqual( data.serialize{object=objects.collection}, "{\n  a = \"yo\",\n  b = 2,\n}\n" )
end

runTests { useANSI = true }
