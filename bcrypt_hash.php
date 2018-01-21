<?php
// Very simple script to generate a bcrypt hash of a passed value.
// Pass in integer value cost, then the value to hash
// php bcrypt_hash.php 12 valueToHash
if (count($argv) != 3) {
    return;
}

$bcryptLevel = intval($argv[1]);
$valueToHash = trim($argv[2]);

$options = [
    'cost' => $bcryptLevel,
];

$result = password_hash($valueToHash, PASSWORD_BCRYPT, $options);

echo $result;