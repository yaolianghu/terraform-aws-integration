package com.example.demo.controller;

import com.example.demo.model.Greeting;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.concurrent.atomic.AtomicLong;

@RestController
public class HelloworldController {

    private AtomicLong counter = new AtomicLong();
    private static final String template = "Hello, %s!";

    @RequestMapping(value="/greeting", method= RequestMethod.GET, produces="application/json")
    public Greeting greeting(@RequestParam(value="name", defaultValue="World Dev") String name) {
        return new Greeting(counter.incrementAndGet(),
                String.format(template, name));
    }


}
