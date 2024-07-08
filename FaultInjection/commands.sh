-----------------------------------------------
Fault injection
-----------------------------------------------

#################################
Setting Up Envoy Proxy
#################################

# => Goto 

https://www.envoyproxy.io/

# Scroll and show

# Click on "Docs" at the top

# Click on the latest version

# Click on the link "Installing Envoy"

# Show the options for the different OSes

# We'll install Envoy using Docker so the set up is the same for Windows and MacOS

# Go to

https://docs.docker.com/get-docker/

# Click on Docker desktop for the 3 platforms (Mac, Windows, Linux)

# Show that we already have Docker running for our machine (Show Docker Desktop)

# On the terminal


docker --version

# Get the Envoy image

docker pull envoyproxy/envoy:v1.29.1

docker run --rm envoyproxy/envoy:v1.29.1 --version


# Set up the envoy-fault-injection.yaml file

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 10000
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          access_log:
          - name: envoy.access_loggers.stdout
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.stream.v3.StdoutAccessLog
          http_filters:
          - name: envoy.filters.http.router
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
          route_config:
            name: local_route
            virtual_hosts:
            - name: local_service
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  host_rewrite_literal: fakestoreapi.com
                  cluster: service_fakestore

  clusters:
  - name: service_fakestore
    type: LOGICAL_DNS
    dns_lookup_family: V4_ONLY
    lb_policy: round_robin
    load_assignment:
      cluster_name: service_fakestore
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: fakestoreapi.com
                port_value: 443
    transport_socket:
      name: fakestore.transport_sockets.tls
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
        sni: fakestoreapi.com



# Run the Envoy proxy server using this custom yaml file

docker run --rm -it \
      -v $(pwd)/envoy-fault-injection.yaml:/envoy-fault-injection.yaml \
      -p 9901:9901 \
      -p 10000:10000 \
      envoyproxy/envoy:v1.29.1 \
          -c /envoy-fault-injection.yaml

# Command on Windows (for reference)

docker run --rm -it
      -v "$PWD\:`"C:\envoy-configs`""
      -p '9901:9901'
      -p '10000:10000'
      'envoyproxy/envoy-windows:v1.29.1'
          -c 'C:\envoy-configs\envoy-fault-injection.yaml'


"

# On Docker Desktop show that the container is running

# Show that it exposes port 10000


# Go to the browser

http://localhost:10000/

# Should see the fakestore API

http://localhost:10000/products

http://localhost:10000/products/1

# Should see the products returned


#################################
Fault Injection
################################# (V1)


# Have a file called FaultInjectionTests.java in the project


import io.restassured.RestAssured;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.http.ContentType;
import io.restassured.response.Response;
import org.testng.annotations.DataProvider;

import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.equalTo;

public class FaultInjectionTests {

    int NUM_REQUESTS = 20;

    @BeforeSuite
    void setup() {
        RestAssured.baseURI = "https://fakestoreapi.com/";
        RestAssured.basePath = "products/1";

        RestAssured.requestSpecification = new RequestSpecBuilder()
                .setContentType(ContentType.JSON)
                .setAccept(ContentType.JSON)
                .build();
    }

    @DataProvider(name = "requests")
    public Object[][] requestsData() {
        Object[][] data = new Object[NUM_REQUESTS][1];
        for (int i = 0; i < NUM_REQUESTS; i++) {
            data[i][0] = i + 1;
        }

        return data;
    }

    @Test(dataProvider = "requests")
    public void loadTest(int requestNumber) {
        Response response = RestAssured.get();

        System.out.println("Request #: " + requestNumber);
        System.out.println("Status Code: " + response.statusCode());
        System.out.println("Response Body: " + response.body().asString());
        System.out.println("-----------------------------------");

        assertThat(response.statusCode(), equalTo(200));
    }

}

# Run the tests, everything should pass

# ===============================================
# Default Suite
# Total tests run: 20, Passes: 20, Failures: 0, Skips: 0
# ===============================================

# Now change the base URI

RestAssured.baseURI = "http://localhost:10000";


# Run the tests again - again everything should pass

# ===============================================
# Default Suite
# Total tests run: 20, Passes: 20, Failures: 0, Skips: 0
# ===============================================


################################# 
################################# 
################################# (V2)

# Add this just under http_filters (one more filter in addition to the one existing)

          - name: envoy.filters.http.fault
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.fault.v3.HTTPFault
              abort:
                http_status: 500
                percentage:
                  numerator: 70
                  denominator: HUNDRED


# The file should now look like this

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 10000
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          access_log:
          - name: envoy.access_loggers.stdout
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.stream.v3.StdoutAccessLog

          http_filters:
          - name: envoy.filters.http.fault
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.fault.v3.HTTPFault
              abort:
                http_status: 500
                percentage:
                  numerator: 70
                  denominator: HUNDRED
          - name: envoy.filters.http.router
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
          route_config:
            name: local_route
            virtual_hosts:
            - name: local_service
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  host_rewrite_literal: fakestoreapi.com
                  cluster: service_fakestore

  clusters:
  - name: service_fakestore
    type: LOGICAL_DNS
    dns_lookup_family: V4_ONLY
    lb_policy: round_robin
    load_assignment:
      cluster_name: service_fakestore
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: fakestoreapi.com
                port_value: 443
    transport_socket:
      name: fakestore.transport_sockets.tls
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
        sni: fakestoreapi.com


# Now back to IntelliJ and run the tests - roughly 70% of the tests should fail

# ===============================================
# Default Suite
# Total tests run: 20, Passes: 5, Failures: 15, Skips: 0
# ===============================================


# => Stop the envoy proxy and change the below block of code in envoy-fault-injection.yaml
# Have a 20% chance that the request will fail with 404 status code

abort:
    http_status: 404
    percentage:
        numerator: 20
        denominator: HUNDRED

# Restart the proxy server                  

# => Now run the tests, roughly 20% fail

# ===============================================
# Default Suite
# Total tests run: 20, Passes: 18, Failures: 2, Skips: 0
# ===============================================

################################# 
################################# 
################################# (V3)

# => Stop the envoy proxy and replace the yaml with the below code
# We are adding a delay of 5 seconds with 50% chance
# If we dont provide any numerator and denominator, it will be considered as 100% chance


# IMPORTANT: Get rid of the abort so we only have the delay


              delay:
                fixed_delay: 5s
                percentage:
                  numerator: 50
                  denominator: HUNDRED

# Restart the proxy server                  


# Config looks like this

static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 10000
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          access_log:
          - name: envoy.access_loggers.stdout
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.stream.v3.StdoutAccessLog

          http_filters:
          - name: envoy.filters.http.fault
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.fault.v3.HTTPFault
              abort:
                http_status: 404
                percentage:
                  numerator: 20
                  denominator: HUNDRED
              delay:
                fixed_delay: 5s
                percentage:
                  numerator: 50
                  denominator: HUNDRED
          - name: envoy.filters.http.router
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
          route_config:
            name: local_route
            virtual_hosts:
            - name: local_service
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  host_rewrite_literal: fakestoreapi.com
                  cluster: service_fakestore

  clusters:
  - name: service_fakestore
    type: LOGICAL_DNS
    dns_lookup_family: V4_ONLY
    lb_policy: round_robin
    load_assignment:
      cluster_name: service_fakestore
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: fakestoreapi.com
                port_value: 443
    transport_socket:
      name: fakestore.transport_sockets.tls
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
        sni: fakestoreapi.com


# Update the tests


    @Test(dataProvider = "requests")
    public void loadTest(int requestNumber) {
        long startTime = System.currentTimeMillis();
        Response response = RestAssured.get();
        long endTime = System.currentTimeMillis();

        int responseTime = (int) (endTime - startTime);

        System.out.println("Request #: " + requestNumber);
        System.out.println("Status Code: " + response.statusCode());
        System.out.println("Response Time (ms): " + responseTime);
        System.out.println("Response Body: " + response.body().asString());
        System.out.println("-----------------------------------");

        assertThat(response.statusCode(), equalTo(200));
        assertThat(responseTime, lessThan(5000));
    }


# Run the tests roughly 50% should pass

# ===============================================
# Default Suite
# Total tests run: 20, Passes: 14, Failures: 6, Skips: 0
# ===============================================

# Add the abort back as well (so we have two faults)


              abort:
                http_status: 404
                percentage:
                  numerator: 20
                  denominator: HUNDRED
              delay:
                fixed_delay: 5s
                percentage:
                  numerator: 50
                  denominator: HUNDRED

# Restart the proxy server                  


# Run the tests the tests will fail due to abort or due to slow website

# Look at the timings in the console on the left to know why the test has failed
# (< 5 seconds and failed, that is an abort)

# ===============================================
# Default Suite
# Total tests run: 20, Passes: 8, Failures: 12, Skips: 0
# ===============================================












































