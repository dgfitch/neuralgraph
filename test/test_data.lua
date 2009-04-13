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

function test_005_Serialize_Can_Ignore()
  local t = {
    a = "yo",
    b = "HOORJ",
  }
  assertEqual( data.serialize{object=t, ignore={b=true}}, "{\n  a = \"yo\",\n}\n" )
end

function test_007_Serialize_SingleNode()
  prepareObjects()
  local node = objects.node.getNew(1,2)
  local s = data.serialize{object=node, ignore=true}
  assertMatches( s, 'x = 1' )
  assertMatches( s, 'y = 2' )
end

function test_007_Serialize_MultipleNodes()
  prepareObjects()
  local node1 = objects.node.getNew(1,2)
  local node2 = objects.node.getNew(3,4)
  table.insert(objects.collection,node1)
  table.insert(objects.collection,node2)
  local s = data.serialize{object=objects.collection, ignore=true}
  assertMatches( s, '1 = {' )
  assertMatches( s, 'x = 1' )
  assertMatches( s, 'y = 2' )
  assertMatches( s, '2 = {' )
  assertMatches( s, 'x = 3' )
  assertMatches( s, 'y = 4' )
end

function test_008_Serialize_NodesAndArc()
  prepareObjects()

  local node1 = objects.node.getNew(1,2)
  local node2 = objects.node.getNew(3,4)
  table.insert(objects.collection,node1)
  table.insert(objects.collection,node2)

  local arc = objects.arc.getNew(node1,node2)
  table.insert(objects.collection,arc)

  local s = data.serialize_cycles{object=objects.collection, name="objects.collection"}
  print(s)
  assertMatches( s, 'objects.collection[3]["type"] = "arc"' )
  assertMatches( s, 'objects.collection[2]["type"] = "node"' )
  assertMatches( s, 'objects.collection[3]["head"] = objects.collection[2]' )
  assertMatches( s, 'objects.collection[3]["tail"] = objects.collection[1]' )
end

runTests { useANSI = true }
