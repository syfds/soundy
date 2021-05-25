unit_test_files = [
 'SoundtouchMessageParser',
 'PresetsParser',
 'GetInfoParser',
 'GetZoneParser',
 'Util',
]

foreach name : unit_test_files
    test(name, executable(name, name + 'Test.vala', src_files, dependencies: dependencies))
endforeach
