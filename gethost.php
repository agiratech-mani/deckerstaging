<?php
function get_domain($url)
    {
      $pieces = parse_url($url);
      $domain = isset($pieces['host']) ? $pieces['host'] : '';
      /*if (preg_match('/(?P<domain>[a-z0-9][a-z0-9\-]{1,63}\.[a-z\.]{2,6})$/i', $domain, $regs)) {
        return $regs['domain'];
      }*/
      return $domain;
    }
 $url = get_domain("https://decker.com/deckerdigital/cti/final?token=58c94eb356c90");
 print_r($url);
?>