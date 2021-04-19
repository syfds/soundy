unit_test_files = [
 'SoundtouchMessageParser',
 'PresetsParser',
]

foreach name : unit_test_files
    test(name, executable(name, name + 'Test.vala', src_files, dependencies: dependencies))
endforeach
