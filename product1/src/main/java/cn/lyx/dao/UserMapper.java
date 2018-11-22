package cn.lyx.dao;


import cn.lyx.entity.User;

public interface UserMapper {


    User selectByPrimaryKey(Integer id);


}