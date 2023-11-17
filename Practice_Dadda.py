def dadda_tree(n, base):
    tree = []
    for i in range(n):
        nodes = base ** (n - i)
        level = []
        for j in range(nodes):
            value = base ** (n - i - 1) + j
            level.append(value)
        tree.append(level)
    
    for level in tree:
        print(level)

# Example usage
dadda_tree(4, 2)
def dadda_tree(n, base):
    tree = []
    for i in range(n):
        nodes = base ** (n - i)
        level = []
        for j in range(nodes):
            value = base ** (n - i - 1) + j
            level.append(value)
        tree.append(level)
    
    for level in tree:
        print(level)
    

