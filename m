From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 2.6.27/28-stable] bas_gigaset: correctly allocate USB
 interrupt transfer buffer
Date: Tue, 24 Mar 2009 10:54:32 +0200
Message-ID: <49C89FC8.9080904@imap.cc>
References: <20090323-patch-01.tilman@imap.cc> <20090323.150005.113220590.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigF0F76293D8EDB051E04E63F4"
Cc: stable@kernel.org, kawk@users.sourceforge.net, hjlipp@web.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from posthamster.phnxsoft.com ([195.227.45.4]:1503 "EHLO
	posthamster.phnxsoft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755259AbZCXI7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 04:59:11 -0400
In-Reply-To: <20090323.150005.113220590.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigF0F76293D8EDB051E04E63F4
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Mon, 23 Mar 2009 15:00:05 -0700 (PDT), David Miller wrote:
> From: Tilman Schmidt <tilman@imap.cc>
> Date: Mon, 23 Mar 2009 22:47:06 +0100 (CET)
>=20
>> the following patch backports the Gigaset driver bugfix merged for
>> 2.6.29 as commit 170ebf85160dd128e1c4206cc197cce7d1424705 to both
>> v2.6.27.x and v2.6.28.x. I would appreciate to see it included in
>> your stable series.
>=20
> If you ask me I can and will do it during my networking patch
> -stable submission.

Thanks. Please do so.

Regards,
Tilman

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enigF0F76293D8EDB051E04E63F4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.4 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFJyJ/TQ3+did9BuFsRAuRkAJ0UU27JivQR/wea8k8X5oCFYaCnMQCfSsHY
/blVuLAGB/4H/q5K2MLx5fA=
=wXEu
-----END PGP SIGNATURE-----

--------------enigF0F76293D8EDB051E04E63F4--
