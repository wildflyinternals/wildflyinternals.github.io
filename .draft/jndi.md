Wildfly has a naming subsystem:

```
$ pwd
/Users/weli/projs/WFLY/wildfly
$ ls naming
pom.xml            src                target             wildfly-naming.iml
```

It depends on `jboss-remote-naming` and we can see it from `wildfly/naming/pom.xml`:


```
<dependency>
    <groupId>org.jboss</groupId>
    <artifactId>jboss-remote-naming</artifactId>
</dependency>
```

In `wildfly/pom.xml` it defines the version to use:

```
<version.org.jboss.remote-naming>2.0.4.Final</version.org.jboss.remote-naming>
```

Here is the Github repository of `jboss-remote-naming`:

```
https://github.com/jbossas/jboss-remote-naming
```





