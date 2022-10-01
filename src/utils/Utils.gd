extends Node


func get_all_children(node: Node, depth: int) -> Array:
	var _nodes : Array = []
	for N in node.get_children():
		if N.get_child_count() > 0:
			_nodes.append(N)
			if depth > 0:
				depth -= 1
				_nodes.append_array(get_all_children(N, depth))
		else:
			_nodes.append(N)
	return _nodes
