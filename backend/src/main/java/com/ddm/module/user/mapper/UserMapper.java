package com.ddm.module.user.mapper;

import com.ddm.module.user.entity.SysUser;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Optional;

@Mapper
public interface UserMapper {

    @Select("""
            SELECT id, username, password, real_name, status, create_time, update_time
            FROM sys_user
            WHERE username = #{username}
            LIMIT 1
            """)
    Optional<SysUser> findByUsername(@Param("username") String username);

    @Select("""
            SELECT id, username, password, real_name, status, create_time, update_time
            FROM sys_user
            WHERE id = #{id}
            LIMIT 1
            """)
    Optional<SysUser> findById(@Param("id") Long id);

    @Select("""
            SELECT r.role_code
            FROM sys_role r
            JOIN sys_user_role ur ON ur.role_id = r.id
            WHERE ur.user_id = #{userId}
              AND r.status = 1
            ORDER BY r.id
            """)
    List<String> findRoleCodesByUserId(@Param("userId") Long userId);

    @Select("""
            SELECT p.permission_code
            FROM sys_permission p
            JOIN sys_role_permission rp ON rp.permission_id = p.id
            JOIN sys_user_role ur ON ur.role_id = rp.role_id
            WHERE ur.user_id = #{userId}
              AND p.status = 1
            GROUP BY p.permission_code
            ORDER BY MIN(p.sort_order), MIN(p.id)
            """)
    List<String> findPermissionCodesByUserId(@Param("userId") Long userId);
}
