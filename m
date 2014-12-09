From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 00/16][pull request] Intel Wired LAN Driver
 Updates 2014-12-06
Date: Mon, 08 Dec 2014 18:05:31 -0800
Message-ID: <1418090731.2410.13.camel@jtkirshe-mobl>
References: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20141208.205031.1761143065244503062.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-8K9xu1Wao7TzJ/ZWUYz1"
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5967 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751103AbaLICFc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2014 21:05:32 -0500
In-Reply-To: <20141208.205031.1761143065244503062.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-8K9xu1Wao7TzJ/ZWUYz1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-12-08 at 20:50 -0500, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Sat,  6 Dec 2014 05:01:57 -0800
>=20
> > This series contains updates to i40e and i40evf.
>=20
> Pulled, thanks Jeff.
>=20
> Please take into consideration Joe Perches's feedback to use static
> inlines instead of macros.
>=20
> Thanks.

Thanks, already on-top of it.  It should be in the next round of "fixes"
I submit upstream.

--=-8K9xu1Wao7TzJ/ZWUYz1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUhljrAAoJEOVv75VaS+3OiswQAIhBPWuV+MAi95iCddCnKDbP
Pr9RGcfCDj0vlzw+ALJvivK7FT3jz2TF9UuXcJ0hL9IEJoTgTN/0h4MgNzeUmpvM
leFKyQ9TXjahJ5JcsauwXJ3SYjjnbPgpczOv33k2x1BETSlvt3upx7sQKskaRYF+
h3xjrEmKGgEnhXRxGOOPH8xk8Z8H4PLOb8ShHGF4yaUCgC1OSt4oEcbCXgKP2KPN
cO9nxLpEh9XixYFuFTGTcPWNbPHZaqNkqqVRPXYyHpOJaCRTka+/4nCTsODDLHNU
15J9fxSZazKoDFOygGTCbtYpJrfvtUnt5R8tkyTugLzZeKmJ0WaC8sjlHyrnI+5c
+TeBGUouX3lw1CxYSUeWQkGNTfeP9DzJHXdy+fHzO2kHD3xW2MEAvf+BX3ATJ8QL
iY+0T6vGG8Uucl0YYGuQRHjVp9E/aa08O1lJpNsRaYHwEc0cwZzDLcRGGvvi+Ffm
b1JKeT1jK70BzTbE7nROjdJK40+sJr2bisdiM0pxLbMLyEpqQe4ywGgGnOjnkc2M
GtqmxSaNJC+UehnwbOkZc7S8FNz3bR/Evox/A9NG8tX7I59kBhfBV6QzTipGRKEL
A4IB9RaUDpsWKuBqwBb+ow1fgMs4ovwtcsackR4RARXqTn8m1oEKDuAHxSV2tHCI
omD8InvY9ol8GTn0qkC7
=2KqP
-----END PGP SIGNATURE-----

--=-8K9xu1Wao7TzJ/ZWUYz1--
