private
processBackendKeyData: payload

	session := payload uint32.
	properties at: 'backend_process_id' put: session.
	properties at: 'backend_secret_key' put: payload uint32