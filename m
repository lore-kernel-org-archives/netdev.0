From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Wed, 17 Jan 2007 07:52:13 +0000
Message-ID: <1169020333.9175.15.camel@johannes.berg>
References: <20070116185524.GA5681@dmt>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-kc/KgGLpJh0g4GnBY70B"
Cc: netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	Dan Williams <dcbw@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:53410 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751766AbXAQHwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jan 2007 02:52:35 -0500
To: Marcelo Tosatti <marcelo@kvack.org>
In-Reply-To: <20070116185524.GA5681@dmt>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-kc/KgGLpJh0g4GnBY70B
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-01-16 at 16:55 -0200, Marcelo Tosatti wrote:

> _Please_ review, this driver is targeted for mainline inclusion.
>=20
> There have been almost no comments resulting from the first submission.

We had looked over the previous version a few days ago and noticed that
the biggest part of the code is a mostly generic wireless stack that
you're including along with the driver, essentially all the wlan_*
files. I don't think that's going to fly.

Also a bunch of minor things but I'd rather look over this version again
before commenting on that.

johannes

--=-kc/KgGLpJh0g4GnBY70B
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFrdWt/ETPhpq3jKURAmTnAJ9kfKNsJQfTtSeNnNMMFWj5eptEXgCcCQNR
g1FAM25f8yubFTT5mtQ86lU=
=jytq
-----END PGP SIGNATURE-----

--=-kc/KgGLpJh0g4GnBY70B--

