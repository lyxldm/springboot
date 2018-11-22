package cn.lyx.controller;

import cn.lyx.entity.User;
import cn.lyx.service.TestService1;
import cn.lyx.service.UserService;
import com.alibaba.dubbo.config.annotation.Reference;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {
    @Reference
    private TestService1 testService1;


    @Reference
    private UserService userService;

    @RequestMapping("test")
    public String test(){
        return testService1.test1();
    }


    @RequestMapping("user")
    public User getUser(Integer id){
        return userService.getUserById(id);
    }
}
