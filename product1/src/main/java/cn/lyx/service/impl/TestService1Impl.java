package cn.lyx.service.impl;

import com.alibaba.dubbo.config.annotation.Service;
import cn.lyx.service.TestService1;
import org.springframework.stereotype.Component;

@Service
@Component
public class TestService1Impl implements TestService1 {

    @Override
    public String test1() {
        return "hello";
    }
}
