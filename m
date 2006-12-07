From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 5/7] d80211: remove unused references to sub interface
	data
Date: Thu, 07 Dec 2006 13:29:19 +0100
Message-ID: <1165494559.3582.3.camel@johannes.berg>
References: <20061207004238.540749000@devicescape.com>
	 <20061207004526.GE16252@devicescape.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-zeE66IISsASjyowvUnll"
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:38082 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1032111AbWLGM3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 07:29:32 -0500
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061207004526.GE16252@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-zeE66IISsASjyowvUnll
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2006-12-06 at 16:45 -0800, David Kimdon wrote:
> plain text document attachment (unused-sdata.patch)
> In these three cases the pointer returned by IEEE80211_DEV_TO_SUB_IF()
> is never used.

Good catch, I must have introduced this when converting the prototypes.
Thanks.

johannes

--=-zeE66IISsASjyowvUnll
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFeAke/ETPhpq3jKURAkCMAKC31JJGcaTvfcZV+090m8H5q92BJACcD5tD
+2FhGVg1r25/jXma2+kn7so=
=fnuQ
-----END PGP SIGNATURE-----

--=-zeE66IISsASjyowvUnll--

