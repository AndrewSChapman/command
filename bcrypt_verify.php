<?php
// Verifies a password against a hash
// php bcrypt_verify.php '$2y$12$A1Z.onUsz6mP6GIxoeKCoOLniqGzmhu/gOwU5SZ6dRKEMj7IIFapu' mypassword
if (count($argv) != 3) {
    return;
}

$hashValue = trim($argv[1]);
$valueToVerify = trim($argv[2]);

if (password_verify($valueToVerify, $hashValue)) {
    echo "1";
} else {
    echo "0";
}