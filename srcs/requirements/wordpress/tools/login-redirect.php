<?php
/**
 * Plugin Name: Custom Login Redirect
 */
add_filter('login_redirect', 'custom_login_redirect', 10, 3);
function custom_login_redirect($redirect_to, $request, $user) {
    if (isset($user->roles) && is_array($user->roles)) {
        if (!in_array('administrator', $user->roles)) {
            return home_url();
        }
    }
    return $redirect_to;
}
