include(FetchContent)

function(setup_nextag_embedded_platform)
    FetchContent_Declare(NextagEmbeddedPlatform
            GIT_REPOSITORY https://github.com/Nextag-lasergame/Nextag-Embedded-Platform.git
            GIT_TAG a337a464d5a3c86214bd5f68f414cbdf64687a61)

    FetchContent_MakeAvailable(NextagEmbeddedPlatform)
endfunction(setup_nextag_embedded_platform)