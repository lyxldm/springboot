package cn.lyx.service.impl;

import com.alibaba.dubbo.config.annotation.Service;
import cn.lyx.service.TestService1;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

@Service
@Component
public class TestService1Impl implements TestService1 {

    @Autowired
    private StringRedisTemplate stringRedisTemplate;

    @Override
    public String test1() {
        stringRedisTemplate.opsForValue().set("nmae","luo");
        return "hello";
    }
}
