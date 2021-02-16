<?php
declare(strict_types = 1);

use Mireiawen\cURL\cURL;

require('vendor/autoload.php');

// Discord webhook URL
$url = getenv('DISCORD_HOOK');

/**
 * The error handler
 *
 * @param string $message The error message
 * @param int $code The HTTP response code
 *
 * @return int The HTTP response code sent
 */
function send_error(string $message, int $code = 500) : int
{
	header('Content-Type: text/plain');
	http_response_code($code);
	echo $message, "\n";
	return $code;
}

// Input data
try
{
	$input = json_decode(file_get_contents('php://input'), TRUE, 5, JSON_THROW_ON_ERROR);
}
catch (JsonException $exception)
{
	send_error(sprintf('JSON error: %s', $exception->getMessage()));
	exit(1);
}

if (!isset($input['Value1']))
{
	send_error('Tuote puuttuu', 400);
	exit(0);
}
$Value1 = $input['Value1'];
$Value2 = $input['Value2'] ?? 'Ostoslistabotti';

// Create the Discord message
$message = [
	'content' => sprintf('- %s', $Value1),
	'embeds' => NULL,
	'username' => $Value2,
];

// Encode the message array to JSON
try
{
	$payload = json_encode($message, JSON_THROW_ON_ERROR);
}
catch (JsonException $exception)
{
	send_error($exception->getMessage());
	exit(1);
}

// Prepare new cURL resource
try
{
	$curl = new cURL($url);
	$curl->SetOptions([
			CURLOPT_RETURNTRANSFER => TRUE,
			CURLOPT_POST => TRUE,
			CURLOPT_POSTFIELDS => $payload,
			CURLOPT_HTTPHEADER => [
				'Content-type: application/json',
			],
		]
	);
	$result = $curl->Execute();
}
catch (Exception $exception)
{
	send_error($exception->getMessage());
	exit(1);
}

send_error(sprintf('%s lisätty ostoslistalle', $Value1), 200);
