from graphviz import Digraph

def visualize_weighted_binary_tree():
    dot = Digraph(comment='Weighted Binary Tree')

    # Level 0
    dot.node('A', '1')

    # Level 1
    dot.node('B', '2')
    dot.node('C', '3')

    # Level 2
    dot.node('D', '4')
    dot.node('E', '5')
    dot.node('F', '6')
    dot.node('G', '7')

    # Edges for Level 0 to Level 1
    dot.edge('A', 'B')
    dot.edge('A', 'C')

    # Edges for Level 1 to Level 2
    dot.edge('B', 'D')
    dot.edge('B', 'E')
    dot.edge('C', 'F')
    dot.edge('C', 'G')

    # Print the generated source code
    print(dot.source)

    # Save and render the image. The format can be changed to 'png', 'jpg', etc.
    dot.render('output/weighted_tree', view=True, format='png')

visualize_weighted_binary_tree()

