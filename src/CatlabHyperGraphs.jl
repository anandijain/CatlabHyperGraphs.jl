module CatlabHyperGraphs

using Catlab, Catlab.Theories
using Catlab.CategoricalAlgebra
using Catlab.Graphs
using Catlab.Graphics
"""
# In this schema:

# V represents the set of vertices.
# E represents the set of hyperedges.
# HE represents the set of hyperedge-vertex pairs, i.e., the connections between hyperedges and vertices.
# src is a morphism that connects a hyperedge-vertex pair to a hyperedge.
# tgt is a morphism that connects a hyperedge-vertex pair to a vertex.
"""
@present SchHyperGraph(FreeSchema) begin
    V::Ob
    E::Ob
    HE::Ob
    src::Hom(HE, E)
    tgt::Hom(HE, V)
end

# this is a little sussy
@abstract_acset_type AbstractHyperGraph <: HasGraph

@acset_type HyperGraph(SchHyperGraph, index=[:src, :tgt]) <: AbstractHyperGraph

function is_directed_multigraph(h::HyperGraph)
    for hyperedge in ne(h)
        # Get the vertices connected to the current hyperedge
        connected_vertices = incident(h, hyperedge, :src)

        # Check if the hyperedge connects exactly two vertices
        if length(connected_vertices) != 2
            return false
        end
    end

    return true
end


function hypergraph_to_graph(h::HyperGraph)
    if !is_directed_multigraph(h)
        error("The hypergraph cannot be converted to a directed multigraph.")
    end

    # Create a new empty Graph
    g = @acset Graph begin
        V = nparts(h, :V)
        E = 0
        src = Int[]
        tgt = Int[]
    end

    # Iterate through the hyperedges of the hypergraph
    for hyperedge in edges(h)
        # Get the vertices connected to the hyperedge
        connected_vertices = h[incident(h, hyperedge, :src), :tgt]

        # Add an edge in the directed multigraph
        add_parts!(g, :E, 1, src=[connected_vertices[1]], tgt=[connected_vertices[2]])
    end

    return g
end

function graph_to_hypergraph(g::Graph)
    # Create a new empty HyperGraph
    h = @acset HyperGraph begin
        V = nparts(g, :V)
        E = nparts(g, :E)
        HE = 0
        src = Int[]
        tgt = Int[]
    end

    # Iterate through the edges of the graph
    for edge in edges(g)
        # Get the source and target vertices of the edge
        src_vertex = g[edge, :src]
        tgt_vertex = g[edge, :tgt]

        # Add a hyperedge and two hyperedge-vertex pairs to the hypergraph
        # add_parts!(h, :H, 1)
        add_parts!(h, :HE, 2, src=[edge, edge], tgt=[src_vertex, tgt_vertex])
    end

    return h
end

export HyperGraph, SchHyperGraph, is_directed_multigraph, hypergraph_to_graph, graph_to_hypergraph

end # module CatlabHyperGraphs
