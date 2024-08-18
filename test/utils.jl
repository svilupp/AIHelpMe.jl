using AIHelpMe: last_result, LAST_RESULT, remove_pkgdir, load_index_hdf5, find_new_chunks

@testset "remove_pkgdir" begin
    path = pkgdir(AIHelpMe) * "/some/other/path"
    @test remove_pkgdir(path, AIHelpMe) == "/some/other/path"
    path2 = pkgdir(Test) * "/some/other/path2"
    @test remove_pkgdir(path2, Test) == "/some/other/path2"
end

@testset "last_result" begin
    @test last_result() == LAST_RESULT
end

@testset "find_new_chunks" begin
    old_chunks = ["chunk1", "chunk2", "chunk3"]
    new_chunks = ["chunk2", "chunk3", "chunk4", "chunk5"]

    # Test where some chunks are new
    new_items_mask = find_new_chunks(old_chunks, new_chunks)
    @test sum(new_items_mask) == 2 # Expecting two new items
    @test new_items_mask == [false, false, true, true]

    # Test with no new chunks
    new_items_mask = find_new_chunks(old_chunks, old_chunks)
    @test sum(new_items_mask) == 0 # Expecting no new items
    @test all(.!new_items_mask)

    # Test with all new chunks
    entirely_new_chunks = ["chunk6", "chunk7"]
    new_items_mask = find_new_chunks(old_chunks, entirely_new_chunks)
    @test sum(new_items_mask) == length(entirely_new_chunks) # Expecting all items to be new
    @test all(new_items_mask)
end

@testset "load_index_hdf5" begin
    index = ChunkIndex(chunks = ["chunk1", "chunk2"],
        embeddings = ones(100, 2),
        tags = nothing,
        tags_vocab = nothing,
        sources = ["source1", "source2"])

    path, _ = mktemp()
    h5open(path, "w") do file
        file["id"] = string(index.id)
        file["chunks"] = index.chunks
        file["sources"] = index.sources
        file["embeddings"] = index.embeddings
    end
    test_index = load_index_hdf5(path)
    @test test_index.id == index.id
    @test test_index.chunks == index.chunks
    @test test_index.sources == index.sources
    @test test_index.embeddings == index.embeddings
end
