export interface Auth0HealthStatus {
  domain: string;
  isReachable: boolean;
  configValid: boolean;
  dnsResolvable: boolean;
  timestamp: string;
  error?: string;
  details: {
    domain: string;
    clientId: string;
    audience: string;
    apiUrl: string;
  };
}

export const validateAuth0Config = (): {
  isValid: boolean;
  errors: string[];
} => {
  const errors: string[] = [];

  const domain = import.meta.env.VITE_AUTH0_DOMAIN;
  const clientId = import.meta.env.VITE_AUTH0_CLIENT_ID;
  const audience = import.meta.env.VITE_AUTH0_AUDIENCE;

  if (!domain) {
    errors.push('VITE_AUTH0_DOMAIN is missing');
  } else if (!domain.includes('.auth0.com')) {
    errors.push(`Invalid Auth0 domain format: ${domain}`);
  }

  if (!clientId) {
    errors.push('VITE_AUTH0_CLIENT_ID is missing');
  } else if (clientId.length < 20) {
    errors.push('VITE_AUTH0_CLIENT_ID appears invalid (too short)');
  }

  if (!audience) {
    errors.push('VITE_AUTH0_AUDIENCE is missing');
  } else if (!audience.startsWith('https://')) {
    errors.push('VITE_AUTH0_AUDIENCE should start with https://');
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};

export const checkAuth0Reachable = async (): Promise<boolean> => {
  try {
    const domain = import.meta.env.VITE_AUTH0_DOMAIN;
    if (!domain) return false;

    const response = await fetch(
      `https://${domain}/.well-known/openid-configuration`,
      {
        method: 'HEAD',
        mode: 'no-cors',
      }
    );

    return true;
  } catch (error) {
    console.error('Auth0 reachability check failed:', error);
    return false;
  }
};

export const getAuth0HealthStatus = async (): Promise<Auth0HealthStatus> => {
  const domain = import.meta.env.VITE_AUTH0_DOMAIN || 'unknown';
  const clientId = import.meta.env.VITE_AUTH0_CLIENT_ID || 'unknown';
  const audience = import.meta.env.VITE_AUTH0_AUDIENCE || 'unknown';
  const apiUrl = import.meta.env.VITE_API_BASE_URL || 'unknown';

  const configValidation = validateAuth0Config();
  const isReachable = await checkAuth0Reachable();

  return {
    domain,
    isReachable,
    configValid: configValidation.isValid,
    dnsResolvable: isReachable,
    timestamp: new Date().toISOString(),
    error: configValidation.errors.length > 0 ? configValidation.errors[0] : undefined,
    details: {
      domain,
      clientId: clientId !== 'unknown' ? `${clientId.substring(0, 10)}...` : clientId,
      audience,
      apiUrl,
    },
  };
};

export const logAuth0Diagnostics = async (): Promise<void> => {
  console.group('Auth0 Diagnostics');

  const status = await getAuth0HealthStatus();

  console.log('Configuration Status:', status.configValid ? '✓ Valid' : '✗ Invalid');
  console.log('Domain Reachable:', status.isReachable ? '✓ Yes' : '✗ No');
  console.log('Timestamp:', status.timestamp);

  if (status.error) {
    console.error('Configuration Error:', status.error);
  }

  console.table(status.details);
  console.groupEnd();

  return;
};

export const createAuth0ErrorBoundary = (error: any): {
  isCritical: boolean;
  message: string;
  suggestedAction: string;
} => {
  const errorStr = String(error).toLowerCase();

  if (errorStr.includes('refused') || errorStr.includes('connect')) {
    return {
      isCritical: true,
      message: 'Unable to connect to Auth0 server',
      suggestedAction:
        'Check your internet connection and verify Auth0 domain in .env.local',
    };
  }

  if (errorStr.includes('cors') || errorStr.includes('origin')) {
    return {
      isCritical: true,
      message: 'CORS policy blocking Auth0 connection',
      suggestedAction:
        'Add your application URL to CORS Allowed Origins in Auth0 dashboard',
    };
  }

  if (errorStr.includes('timeout') || errorStr.includes('econnrefused')) {
    return {
      isCritical: true,
      message: 'Auth0 server not responding (timeout)',
      suggestedAction:
        'Check if Auth0 service is operational or try again in a moment',
    };
  }

  if (errorStr.includes('invalid domain') || errorStr.includes('malformed')) {
    return {
      isCritical: false,
      message: 'Invalid Auth0 configuration',
      suggestedAction: 'Verify VITE_AUTH0_DOMAIN is correct in .env.local',
    };
  }

  return {
    isCritical: false,
    message: 'Unknown Auth0 error',
    suggestedAction: 'Check browser console for detailed error message',
  };
};
