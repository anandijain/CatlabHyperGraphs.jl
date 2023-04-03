
using CatlabHyperGraphs
using Catlab, Catlab.Theories
using Catlab.CategoricalAlgebra
using Catlab.Graphs
using Catlab.Graphics
using AlgebraicRewriting
using JSON

using Test

# to_graphviz(SchHyperGraph)

h = @acset HyperGraph begin
    V = 3
    H = 2
    HE = 5
    src = [1, 1, 1, 2, 2]
    tgt = [1, 2, 3, 3, 2]
end

# Create the initial hypergraph with 4 vertices and no edges
h = @acset HyperGraph begin
    V = 4
    H = 0
    HE = 0
    src = Int[]
    tgt = Int[]
end

# Add a new vertex
add_parts!(h, :V, 1)

# Add a new hyperedge that connects vertices (1, 2, 4)
add_parts!(h, :H, 1)
add_parts!(h, :HE, 3, src=[1, 1, 1], tgt=[1, 2, 4])

@test h == parse_json_acset(HyperGraph, JSON.json(generate_json_acset(h)))

@test !is_directed_multigraph(h)
@test_throws Any hypergraph_to_graph(h)

g = @acset Graph begin
    V = 4
    E = 1
    src = [1]
    tgt = [2]
end

gh = graph_to_hypergraph(g)
hg = hypergraph_to_graph(gh)
@test g == hg

g2 = @acset Graph begin
    V = 5
    E = 4
    src = [1, 2, 3, 4]
    tgt = [2, 3, 4, 5]
end

gh2 = graph_to_hypergraph(g2)
hg2 = hypergraph_to_graph(gh2)
@test is_directed_multigraph(gh2)
@test g2 == hg2

# Two isomorphic hypergraphs
h1 = @acset HyperGraph begin
    V = 4
    H = 2
    HE = 6
    src = [1, 1, 1, 2, 2, 2]
    tgt = [1, 2, 3, 2, 3, 4]
end

h2 = @acset HyperGraph begin
    V = 4
    H = 2
    HE = 6
    src = [1, 1, 1, 2, 2, 2]
    tgt = [1, 3, 2, 2, 4, 3]
end

h3 = @acset HyperGraph begin
    V = 4
    H = 2
    HE = 5
    src = [1, 1, 1, 2, 2]
    tgt = [1, 2, 3, 2, 3]
end

@test !isempty(isomorphisms(h1, h2))
@test isempty(isomorphisms(h1, h3))
