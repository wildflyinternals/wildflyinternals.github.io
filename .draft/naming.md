https://docs.jboss.org/author/display/WFLY8/Remote+JNDI+Configuration

 Remote JNDI Configuration
Skip to end of metadata

    Added by Eduardo Martins, last edited by Eduardo Martins on Apr 02, 2014  (view change)

Go to start of metadata
Remote JNDI Configuration

The Naming subsystem configuration may be used to (de)activate the remote JNDI interface, which allows clients to lookup entries present in a remote WildFly instance.
	Only entries within the java:jboss/exported context are accessible over remote JNDI.

In the subsystem's XML configuration, remote JNDI access bindings are configured through the <remote-naming /> XML element:
<remote-naming />

Management clients, such as the WildFly CLI, may be used to add/remove the remote JNDI interface. An example to add and remove the one in the XML example above:
/subsystem=naming/service=remote-naming:add
/subsystem=naming/service=remote-naming:remove

`naming` subsystem:

```
/*
 * JBoss, Home of Professional Open Source.
 * Copyright 2012, Red Hat, Inc., and individual contributors
 * as indicated by the @author tags. See the copyright.txt file in the
 * distribution for a full listing of individual contributors.
 *
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, write to the Free
 * Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA, or see the FSF site: http://www.fsf.org.
 */

package org.jboss.as.naming.remote;

import java.io.IOException;
import java.util.Hashtable;
import java.util.concurrent.ExecutorService;
import javax.naming.Context;
import org.jboss.as.naming.NamingContext;
import org.jboss.as.naming.NamingStore;
import org.jboss.msc.inject.Injector;
import org.jboss.msc.service.Service;
import org.jboss.msc.service.ServiceName;
import org.jboss.msc.service.StartContext;
import org.jboss.msc.service.StartException;
import org.jboss.msc.service.StopContext;
import org.jboss.msc.value.InjectedValue;
import org.jboss.naming.remote.server.RemoteNamingService;
import org.jboss.remoting3.Endpoint;

/**
 * @author John Bailey
 */
public class RemoteNamingServerService implements Service<RemoteNamingService> {
    public static final ServiceName SERVICE_NAME = ServiceName.JBOSS.append("naming", "remote");
    private final InjectedValue<ExecutorService> executorService = new InjectedValue<ExecutorService>();
    private final InjectedValue<Endpoint> endpoint = new InjectedValue<Endpoint>();
    private final InjectedValue<NamingStore> namingStore = new InjectedValue<NamingStore>();
    private RemoteNamingService remoteNamingService;

    public synchronized void start(StartContext context) throws StartException {
        try {
            final Context namingContext = new NamingContext(namingStore.getValue(), new Hashtable<String, Object>());
            remoteNamingService = new RemoteNamingService(namingContext, executorService.getValue(), RemoteNamingLogger.INSTANCE);
            remoteNamingService.start(endpoint.getValue());
        } catch (Exception e) {
            throw new StartException("Failed to start remote naming service", e);
        }
    }

    public synchronized void stop(StopContext context) {
        try {
            remoteNamingService.stop();
        } catch (IOException e) {
            throw new IllegalStateException("Failed to stop remote naming service", e);
        }
    }

    public synchronized RemoteNamingService getValue() throws IllegalStateException, IllegalArgumentException {
        return remoteNamingService;
    }

    public Injector<ExecutorService> getExecutorServiceInjector() {
        return executorService;
    }

    public Injector<Endpoint> getEndpointInjector() {
        return endpoint;
    }

    public Injector<NamingStore> getNamingStoreInjector() {
        return namingStore;
    }
}

```

```
vpn1-5-24:naming weli$ grep -r 'jboss/exported' *
src/main/java/org/jboss/as/naming/deployment/ContextNames.java:     * ServiceName for java:jboss/exported namespace
src/main/java/org/jboss/as/naming/deployment/ContextNames.java:                sb.append("java:jboss/exported/");
*** src/main/java/org/jboss/as/naming/deployment/ContextNames.java:        if(bindName.startsWith("jboss/exported/")) { ***
src/main/java/org/jboss/as/naming/InitialContext.java:                        namespace = "jboss/exported";
src/main/java/org/jboss/as/naming/management/JndiViewOperation.java:                        addEntries(contextsNode.get("java:jboss/exported"), new NamingContext(exportedContextNamingStore, null));
src/main/java/org/jboss/as/naming/management/JndiViewOperation.java:                        throw new OperationFailedException(e, new ModelNode().set(NamingLogger.ROOT_LOGGER.failedToReadContextEntries("java:jboss/exported")));
src/main/java/org/jboss/as/naming/service/DefaultNamespaceContextSelectorService.java:                } else if (identifier.equals("jboss/exported")) {
src/main/java/org/jboss/as/naming/ServiceBasedNamingStore.java:            return new CompositeName("java:jboss/exported");
src/main/resources/schema/jboss-as-naming_1_2.xsd:                This element activates the remote naming server, that allows access to items bound in the java:jboss/exported
src/main/resources/schema/jboss-as-naming_1_3.xsd:                This element activates the remote naming server, that allows access to items bound in the java:jboss/exported
src/main/resources/schema/jboss-as-naming_1_4.xsd:                This element activates the remote naming server, that allows access to items bound in the java:jboss/exported
src/main/resources/schema/jboss-as-naming_2_0.xsd:                This element activates the remote naming server, that allows access to items bound in the java:jboss/exported
Binary file target/classes/org/jboss/as/naming/deployment/ContextNames$BindInfo.class matches
Binary file target/classes/org/jboss/as/naming/deployment/ContextNames.class matches
Binary file target/classes/org/jboss/as/naming/InitialContext$DefaultInitialContext.class matches
Binary file target/classes/org/jboss/as/naming/management/JndiViewOperation$1.class matches
Binary file target/classes/org/jboss/as/naming/service/DefaultNamespaceContextSelectorService$1.class matches
Binary file target/classes/org/jboss/as/naming/ServiceBasedNamingStore.class matches
target/classes/schema/jboss-as-naming_1_2.xsd:                This element activates the remote naming server, that allows access to items bound in the java:jboss/exported
target/classes/schema/jboss-as-naming_1_3.xsd:                This element activates the remote naming server, that allows access to items bound in the java:jboss/exported
target/classes/schema/jboss-as-naming_1_4.xsd:                This element activates the remote naming server, that allows access to items bound in the java:jboss/exported
target/classes/schema/jboss-as-naming_2_0.xsd:                This element activates the remote naming server, that allows access to items bound in the java:jboss/exported
vpn1-5-24:naming weli$
```

------

https://docs.jboss.org/author/display/WFLY8/Remote+JNDI+Reference

final Properties env = new Properties();
env.put(Context.INITIAL_CONTEXT_FACTORY, org.jboss.naming.remote.client.InitialContextFactory.class.getName());
env.put(Context.PROVIDER_URL, "remote://localhost:4447");
remoteContext = new InitialContext(env);


src/main/java/org/jboss/as/naming/subsystem/RemoteNamingAdd.java


------


The Java EE platform specification defines the following JNDI contexts:

    java:comp - The namespace is scoped to the current component (i.e. EJB)
    java:module - Scoped to the current module
    java:app - Scoped to the current application
    java:global - Scoped to the application server


https://docs.jboss.org/author/display/WFLY10/JNDI+Reference


------

```
public class RemoteNamingAdd extends AbstractAddStepHandler {

    static final RemoteNamingAdd INSTANCE = new RemoteNamingAdd();

    private RemoteNamingAdd() {
    }

    @Override
    protected void performRuntime(OperationContext context, ModelNode operation, ModelNode model) throws OperationFailedException {

        installRuntimeServices(context);
    }

    void installRuntimeServices(final OperationContext context) throws OperationFailedException {

        final RemoteNamingServerService remoteNamingServerService = new RemoteNamingServerService();

        final ServiceBuilder<RemoteNamingService> builder = context.getServiceTarget().addService(RemoteNamingServerService.SERVICE_NAME, remoteNamingServerService);
        builder.addDependency(RemotingServices.SUBSYSTEM_ENDPOINT, Endpoint.class, remoteNamingServerService.getEndpointInjector())
                .addDependency(ContextNames.EXPORTED_CONTEXT_SERVICE_NAME, NamingStore.class, remoteNamingServerService.getNamingStoreInjector())
                .addInjection(remoteNamingServerService.getExecutorServiceInjector(), Executors.newFixedThreadPool(10))
                .setInitialMode(ServiceController.Mode.ACTIVE)
                .install();
    }
```

-------

vpn1-5-24:naming weli$ mate target/classes/schema/jboss-as-naming_2_0.xsd






