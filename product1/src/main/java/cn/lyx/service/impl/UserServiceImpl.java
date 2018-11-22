package cn.lyx.service.impl;

import cn.lyx.dao.UserMapper;
import cn.lyx.entity.User;
import cn.lyx.service.UserService;
import com.alibaba.dubbo.config.annotation.Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;

@Service
@Component
public class UserServiceImpl implements UserService {
    @Autowired
    private UserMapper userMapper;

    @Autowired
    private StringRedisTemplate stringRedisTemplate;

    @Override
    public User getUserById(Integer id) {
        User user =  userMapper.selectByPrimaryKey(id);
        stringRedisTemplate.opsForValue().set(user.getName(),user.toString(),60*5, TimeUnit.SECONDS);
        return user;
    }
}
