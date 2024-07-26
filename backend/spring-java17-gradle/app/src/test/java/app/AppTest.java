package com.example.demo; // Adjusted package declaration

import org.junit.Test;
import static org.junit.Assert.assertNotNull;

public class AppTest {

    @Test
    public void testAppHasAGreeting() {
        DemoApplication.HelloController classUnderTest = new DemoApplication().new HelloController();
        assertNotNull("app should have a greeting", classUnderTest.hello());
    }
}

