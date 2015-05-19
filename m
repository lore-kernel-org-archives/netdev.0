From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net-next: ethtool: Added port speed macros.
Date: Tue, 19 May 2015 18:00:35 +0100
Message-ID: <1432054835.12412.28.camel@decadent.org.uk>
References: <1431946907-7808-1-git-send-email-parav.pandit@avagotech.com>
	 <20150518.114630.1938175226193925552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-LkyuLIjYT+fy0x47gxnf"
Cc: parav.pandit@avagotech.com, netdev@vger.kernel.org, bwh@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39773 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753577AbbESRAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 13:00:44 -0400
In-Reply-To: <20150518.114630.1938175226193925552.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-LkyuLIjYT+fy0x47gxnf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-05-18 at 11:46 -0400, David Miller wrote:
> From: Parav Pandit <parav.pandit@avagotech.com>
> Date: Mon, 18 May 2015 16:31:47 +0530
>=20
> > Signed-off-by: Parav Pandit <parav.pandit@avagotech.com>
>=20
> I thought we had decided that we weren't going to keep adding
> convenience macros for new speeds, and were simply going to use
> the appropriate constants in the future.
>=20
> Ben?

That's what I thought, but you accepted commit dcf972a334dd "ethtool,
net/mlx4_en: Add 100M, 20G, 56G speeds ethtool reporting support" not so
long ago.

Ben.

--=20
Ben Hutchings
I'm not a reverse psychological virus.  Please don't copy me into your sig.

--=-LkyuLIjYT+fy0x47gxnf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVVtsM+e/yOyVhhEJAQrTfBAAt0HH6RO/T9Q8wUy6WUoS0OomNH+N7H4Q
TDNmBIWRAZ/On4AEDG9WIVExhmFGv+OLB6YHs0huX9crhnH/JsVqTXHDTDrvlXm5
PNEnjKc1PPNVSjROMb7UahfGOUHmneR0I4a9y3QlQ5dEsr8lR3r8w4Gay//ZEj5E
WqUo+uvTFLO3/PEiigLIrytCt8fvBJJ33HJBpQxZDX+w4ee4WhvIK/ILOydeiKSt
Fyu8/sSJj6+uYXc0/17X6V4K7ifq6kyVdgFkpcumi1Z1y//6aN+77CbEwGEZkkjF
kbgwb73piEF2CwOiuCVTf2ICPzP8pkbUNCJTypDCVKdgzhb/PbHDkucOY9meH8ls
yuAry/PiGDHDyPulTnf3b7sdB4xml/XtC1JyjTzOsPVs+vfBUbcXqMpE4XnQJn4O
8/vFFyaVbdhIKr3fIcip0nNQA7Lzzti516jjb8wfko7UQjT/oyZwMmLuDVSYEMgZ
TRZhwty6oaR0m8k83SFx1lINBnpnxF8ZS/jqpPhv4yJBE+kx2DcG7AGdfOKgfyvR
UUlDfZed0G7XZd5knQf32r0cbrNauakdVxRaFq23qAuP2xfEpv/zO6Zx37k9BMqz
aca+lUOyxGwXPE7KJK6PsRZpmEciTSZxYTMObSD7XI4XH8naN1uifiaMTxf2Lkjq
qM3CcN8gA5w=
=m09Y
-----END PGP SIGNATURE-----

--=-LkyuLIjYT+fy0x47gxnf--
