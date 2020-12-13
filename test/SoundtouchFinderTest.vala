using GLib;


public void test_increment_ip() {

    assert(SoundtouchFinder.increment_ip_address("192.168.1.1") == "192.168.1.2");
}

public int main(string[] args) {
    Test.init(ref args);

    Test.add_func("/test_increment", test_increment_ip);
    return Test.run();
}
