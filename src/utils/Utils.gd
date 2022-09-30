extends Node


func get_all_children(node: Node) -> Array:
	var _nodes : Array = []
	for N in node.get_children():
		if N.get_child_count() > 0:
			_nodes.append(N)
			_nodes.append_array(get_all_children(N))
		else:
			_nodes.append(N)
	return _nodes
