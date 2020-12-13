unit_test_files = [
 'SoundtouchMessageParser',
 'SoundtouchFinder'
]

foreach name : unit_test_files
    test(name, executable(name, name + 'Test.vala', src_files, dependencies: dependencies))
endforeach
