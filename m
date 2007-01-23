From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Tue, 23 Jan 2007 20:13:03 +0100
Message-ID: <1169579584.3649.31.camel@johannes.berg>
References: <20070116185524.GA5681@dmt>
	 <1169046072.2750.10.camel@localhost.localdomain>
	 <1169047134.9175.49.camel@johannes.berg>
	 <1169055788.2550.44.camel@localhost.localdomain>
	 <1169056884.9175.66.camel@johannes.berg> <20070122112613.GA3038@dmt>
	 <9e4733910701220720x47506091m357cbf9e5deb3903@mail.gmail.com>
	 <1169566914.3649.4.camel@johannes.berg>
	 <9e4733910701230818g13dc82a2kf0972b8543db449f@mail.gmail.com>
	 <1169571273.3649.12.camel@johannes.berg>
	 <9e4733910701230914t52b39f2dha00ddfcec22fd3bd@mail.gmail.com>
	 <1169575198.2777.37.camel@localhost.localdomain>
	 <1169577039.3649.29.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-jeXTNCizH7qBxNdDpKgZ"
Cc: Jon Smirl <jonsmirl@gmail.com>,
	Marcelo Tosatti <marcelo@kvack.org>, Jiri Benc <jbenc@suse.cz>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:39323 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932952AbXAWTN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 14:13:59 -0500
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1169577039.3649.29.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-jeXTNCizH7qBxNdDpKgZ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-01-23 at 19:30 +0100, Johannes Berg wrote:

> .11s also introduces new frame types/subtypes that probably need to be
> ACKed which usually the firmware won't do since it doesn't understand
> those frame types/subtypes yet.

This assertion might have been premature, it's entirely possible that
the firmware acks those new unicast frames anyway. Best to just inject
them and try, I suppose.

johannes

--=-jeXTNCizH7qBxNdDpKgZ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFtl4//ETPhpq3jKURAnTcAJ9MdJiJxSm0FPfbwYhMc1sfgxgA2gCfctNb
+4roU1l+G7LEZPFNWBjOOh8=
=pMV7
-----END PGP SIGNATURE-----

--=-jeXTNCizH7qBxNdDpKgZ--

