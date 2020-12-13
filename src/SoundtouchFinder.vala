public class SoundtouchFinder : Object {
    private SoundtouchFinder() {
    }


    public static string find(string start_ip4_address, string end_ip4_address) {
        string temp = start_ip4_address;
        while (temp != end_ip4_address) {
            string next_host_to_try = increment_ip_address(temp);

            message(@"will check $next_host_to_try");

            var client = new SoundtouchClient.from_host(next_host_to_try);

            try {
                string info = client.get_info();
                if ("" != info && null != info && info.size() > 0) {

                    message(@"got it for $next_host_to_try");

                    return next_host_to_try;
                }
            } catch (Error e) {
                error("cannot invoke /info endpoint on " + next_host_to_try, e);
            }

            temp = next_host_to_try;
        }

        return "";
    }

    private string get_current_ip4_address() {
        return "";
    }


    public string get_start_search_range(string ip4_address) {
        return "";
    }
    public string get_end_search_range(string ip4_address) {
        return "";
    }

    public static string increment_ip_address(string ip4_address) {
        if (ip4_address != "") {
            string[] ip_address_split = ip4_address.split(".");
            if (ip_address_split.length == 4) {
                string last_id = ip_address_split[3];
                int last_id_incremented = last_id.to_int() + 1;

                return ip_address_split[0] + "." + ip_address_split[1] + "." + ip_address_split[2] + "." + last_id_incremented.to_string();
            }
        }
        return "";
    }
}
