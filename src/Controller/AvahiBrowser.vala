using Avahi;
public class AvahiBrowser {
    private const string service_type = "_soundtouch._tcp";

    public signal void on_found_speaker(string name, string type, string domain, string hostname, uint16 port, StringList? txt);


    private Client client;
    private MainLoop main_loop;
    private List<ServiceResolver> resolvers = new List<ServiceResolver>();
    private ServiceBrowser service_browser;

    public AvahiBrowser() {
        try {
            service_browser = new ServiceBrowser(service_type);
            service_browser.new_service.connect(on_new_service);
            service_browser.removed_service.connect(on_removed_service);
            client = new Client();
        } catch (Avahi.Error e) {
            message(e.message);
        }
    }

    public void search() {
        main_loop = new MainLoop();
        TimeoutSource time = new TimeoutSource(2000);

        time.set_callback(() => {
            main_loop.quit();
            return false;
        });

        time.attach(main_loop.get_context());
        client.start();
        service_browser.attach(client);
        main_loop.run();
    }

    public void on_found(Interface @interface, Protocol protocol, string name, string type, string domain, string hostname, Address? address, uint16 port, StringList? txt) {
        message("Found name %s, type %s, port %u, hostname %s\n", name, type, port, hostname);
        on_found_speaker(name, type, domain, hostname, port, txt);
    }

    public void on_new_service(Interface @interface, Protocol protocol, string name, string type, string domain, LookupResultFlags flags) {
        ServiceResolver service_resolver = new ServiceResolver(Interface.UNSPEC,
                Protocol.UNSPEC,
                name,
                type,
                domain,
                Protocol.UNSPEC);
        service_resolver.found.connect(on_found);
        service_resolver.failure.connect((error) => {
            warning(error.message);
        });

        try {
            service_resolver.attach(client);
        } catch (Avahi.Error e) {
            warning(e.message);
        }

        resolvers.append(service_resolver);
    }

    public void on_removed_service(Interface @interface, Protocol protocol, string name, string type, string domain, LookupResultFlags flags) {
        message("Removed service %s, type %s domain %s\n", name, type, domain);
    }
}
