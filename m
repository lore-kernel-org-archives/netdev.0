From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH] gigaset: beyond ARRAY_SIZE of iwb->data
Date: Mon, 25 May 2009 12:00:47 +0200
Message-ID: <4A1A6C4F.4030201@imap.cc>
References: <4A15BA76.6080007@gmail.com> <20090521.150424.115610710.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig6E32F646C4F2828BD86AC19B"
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	gigaset307x-common@lists.sourceforge.net, hjlipp@web.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:39816 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752364AbZEYKA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2009 06:00:58 -0400
In-Reply-To: <20090521.150424.115610710.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig6E32F646C4F2828BD86AC19B
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 22.05.2009 00:04 schrieb David Miller:
> From: Roel Kluin <roel.kluin@gmail.com>
> Date: Thu, 21 May 2009 22:32:54 +0200
>=20
>> Do not go beyond ARRAY_SIZE of iwb->data
>>
>> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
>> ---
>> Sorry for the dup, the header was incorrect. This is against linux-nex=
t.
>=20
> Applied to net-2.6

Thanks for the CC. Unfortunately I didn't receive the original patch, nor=

can I find it on LKML. Could someone send me a copy please so that I can
check it before it gets merged?

Thanks,
Tilman

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enig6E32F646C4F2828BD86AC19B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4-svn0 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iD8DBQFKGmxYQ3+did9BuFsRAmfPAJ9m5EWORrxnOaFqO0V7nXnQiZDDvQCfVjQP
kmBso0igomExWzGTvmZZ0OM=
=OQZ0
-----END PGP SIGNATURE-----

--------------enig6E32F646C4F2828BD86AC19B--
