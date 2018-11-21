package cn.lyx;

import com.alibaba.dubbo.config.spring.context.annotation.EnableDubbo;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@EnableDubbo

public class Product1Application {

	public static void main(String[] args) {
		SpringApplication.run(Product1Application.class, args);
	}
}
