From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 0/4] intel: string and rx tstamping cleanups
Date: Tue, 01 Apr 2014 18:44:57 -0700
Message-ID: <1396403097.2230.1.camel@jtkirshe-mobl>
References: <1396399939-18420-1-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1UG0WJbw3p+aIgdEgJmq"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39916 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751676AbaDBBpK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2014 21:45:10 -0400
In-Reply-To: <1396399939-18420-1-git-send-email-kubakici@wp.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1UG0WJbw3p+aIgdEgJmq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-04-02 at 02:52 +0200, Jakub Kicinski wrote:
> This series contains promised string fixes and small cleanups for rx
> time
> stamping code in igb and ixgbe.
>=20
> String cleanups are limited to new line termination. Joe Perches
> suggested
> more improvements that seem worthwhile. [1]
>=20
> Rx time stamping path in igb and ixgbe was redesigned few times in the
> past
> and there are some small errors and leftovers from previous versions
> so=20
> I clean it up a little too.

Thanks Jakub, I will add your series to my queue.

--=-1UG0WJbw3p+aIgdEgJmq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTO2uZAAoJEOVv75VaS+3OSn8P/29z0G1j6e6m4F2hLBChmgMd
Gj+AP22LBWM12tai4/QTLgzIgYwKne4mjbCVydqpQJPkHKGJODIRz+LBCrlCxJjK
K+t9w4SgHreDSVTk0CXYyRKggw4Ua4SoJHJ76cNblDDWM3q7+kYPDleFjwC9IAcF
iLx9fYUlGPoshz8dYMb210ESI0C6ptmSYKrive1vFfSkjuQDTFkpLBtu8gTQ2SNc
0up0j5COTIz8hX6I8I+XNFJg5dboSty6XMxcl4K3HnpqsL3Bzy4/TR9zCscQ8Kkd
r0+iVGkokNzZEX8yBIkv9Z/5kgDsQ8YD5M4JkJSaAPCgxDJGrfCZS+jIMmjQXm29
NRgrDHuJXJGKynsblbsMTSbnc4T3AygyKL0xTE1yDMf3tVeiEDIRS30L+o7zioXA
nEm9NcKImzXyRuDcmAoNWYPBHJvvk02ef9+T0E2+Q6FbCn5nN6rNiC8IVZ/xQ/8y
tvteQz6aTFxp01K4GasGhpgb69jLBLjoDMmLyQtcLvsAabK4cVGtQG5T+WObxsCl
s1KTP5hEJwo4VCZMK7OhwViJkteqiNesNdSX+Hm/hXIaSgRPVDRZhaw2V3jx5o80
uB3PMkGDxnJp1rjDtctJyt366af6xkMeFNarxpsAko17ogeRVTzPi6zYPwMow85n
8e2Dhvop47dMV9EShbxU
=Js6b
-----END PGP SIGNATURE-----

--=-1UG0WJbw3p+aIgdEgJmq--
