From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net] ixgbe: Do not pad FCoE frames as this can cause issues
 with FCoE DDP
Date: Tue, 26 Jun 2012 00:47:30 -0700
Message-ID: <1340696850.2255.17.camel@jtkirshe-mobl>
References: <1340695993-1911-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20120626.004302.1065943933933136878.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-OqOEv/O59v1ia64SWK24"
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46312 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754651Ab2FZHre (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 03:47:34 -0400
In-Reply-To: <20120626.004302.1065943933933136878.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-OqOEv/O59v1ia64SWK24
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-06-26 at 00:43 -0700, David Miller wrote:
> You can't put things like "[3.4]" unquoted into the CC: list, that's
> not kosher and vger rejected it.

Sorry, that was what Greg told me to do.  I did not realize it needed to
be in quotes, my bad.

--=-OqOEv/O59v1ia64SWK24
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJP6WkSAAoJEOVv75VaS+3O0iEQAJ9yj+GfBlNfgL7AO+LFCLZs
JnkQOGptmClBVPI+LVuoT/DWEh5of9oFfFz9cOrPjWkfCoT4QvDCw174iaFxfWal
p5XllnuHFzCwZ6Lm5VUddoxrRrcxqdr7+S8JG1yFZK1Rb8uyBRVL5TiK1Lx+b7ol
OrGdFBsYGgh5ffAQV1iLdptHqEa0Ssf0/p7QuiE4ELtZLkXJgR7cINnwE427Kd6t
d9oUEApRfnTFXJwRyFj90nWwULFbAQvrzJMKKkIj1bGYul/gLXPq1eXLq0CcR2lJ
SDeUluj0uNUbp9eF486SC+z2Kz1zF9kuzH8W4c2wQnXZLipDdYLByAcHyUIF2JBW
nUiIFPcZMvvGhObqN2Gxrrq2WpY+s2TmZpSXu82omXCn//UBsy7vNJ5kOGPGDZqY
dxGgzPU7tL8tmOBvE4QHI2zNov58O9nqfMaK+J21zeon9a/O7nqnFsWBEEPoytiP
1r23Nhu74aRQXUjvHuLARvm2L+HMnCdrMj+OhqmPwGyOns8GttUa1eE+C8ulD5yt
uWuprbCN0w0OahHD2I11PmbO4l7KdbiVWCPG+85Oeibgk4EVVSE0DhlZ457mcV4Z
AOLsLqSGCsfR1Q+0iO4XZYJ09s/XSMBcQ2hVCVJXBq+TAjk8O2FyONXMZoA7vIU8
ZffYWBr92BSpywi8rcW7
=KBBN
-----END PGP SIGNATURE-----

--=-OqOEv/O59v1ia64SWK24--
