package ie.ucd.serverjavafiles;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurerAdapter;
import org.springframework.web.servlet.view.InternalResourceViewResolver;
import org.thymeleaf.extras.springsecurity4.dialect.SpringSecurityDialect;

@Configuration
public class MvcConfig extends WebMvcConfigurerAdapter {
    
    // This method sets up a registry for login. This is not included in GreetingController due to the additional settings provided by SpringSecurity.
    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        registry.addViewController("/login").setViewName("login");
        registry.setOrder(Ordered.HIGHEST_PRECEDENCE);
    }
    
    // This method configures Autowired annotations set to the value dataSource. Any class using a dataSource should use @Autowired DataSource dataSource to connect to set up the datasource to these settings.
    @Bean(name = "dataSource")
    public DriverManagerDataSource dataSource() {
        DriverManagerDataSource driverManagerDataSource = new DriverManagerDataSource();
        driverManagerDataSource.setDriverClassName("com.mysql.jdbc.Driver");
        driverManagerDataSource.setUrl("jdbc:mysql://localhost:3306/who_there_db?autoReconnect=true&useSSL=false");
        // Our Project's MySql Database username is set to "root" and the password is set to "goldilocks"
        driverManagerDataSource.setUsername("root");
        driverManagerDataSource.setPassword("Rufiedog101010");
        return driverManagerDataSource;
    }
    
    // This method configures the SpringSecurityDialect in order to allow Thymeleaf in HTML documents. No further config is necessary to use Thymeleaf
    @Bean
    public SpringSecurityDialect springSecurityDialect(){
        return new SpringSecurityDialect();
    }
    
    // While HTML files do not require a dedicated resolver, I have included it in case we wish to have a template for resolving other resources, such as .JSP. 
    // If resolving other types, you can set up the resolver similar to below to allow it to be resolved on our server via URL.
    @Bean
    public InternalResourceViewResolver viewResolver() {
	InternalResourceViewResolver resolver = new InternalResourceViewResolver();
	resolver.setPrefix("/resources/templates/");
	resolver.setSuffix(".html");
	return resolver;
    }
    
}
