From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Kernel bug in bcm43xx-d80211
Date: Mon, 19 Feb 2007 23:12:08 +0100
Message-ID: <1171923128.15489.35.camel@johannes.berg>
References: <358127.50930.qm@web50203.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-WWi/LZWd6owlzat+KNSr"
Cc: netdev@vger.kernel.org
To: Alex Davis <alex14641@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:51025 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932480AbXBSWMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 17:12:21 -0500
In-Reply-To: <358127.50930.qm@web50203.mail.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-WWi/LZWd6owlzat+KNSr
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-02-19 at 13:48 -0800, Alex Davis wrote:
> I go the following Oops with the latest wireless-dev git when starting wp=
a_supplicant:
>=20
> Feb 19 16:17:42 boss kernel: [  377.359573] BUG: unable to handle kernel =
NULL pointer dereference
> at virtual address 00000002

Probably caused by my recent changes that accidentally broke d80211
pretty much completely. Patches are on the linux-wireless mailing list.

johannes

--=-WWi/LZWd6owlzat+KNSr
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF2iC1/ETPhpq3jKURAo4EAJwN9cvb4bukg8dbh0VuUYHbex1XDQCfT8sT
KdaReMT48u4w4qMjVNAvh2M=
=Vtby
-----END PGP SIGNATURE-----

--=-WWi/LZWd6owlzat+KNSr--

