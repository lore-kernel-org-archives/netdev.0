From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Tue, 23 Jan 2007 19:30:39 +0100
Message-ID: <1169577039.3649.29.camel@johannes.berg>
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
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-WIiomWNq297cBvah22oy"
Cc: Jon Smirl <jonsmirl@gmail.com>,
	Marcelo Tosatti <marcelo@kvack.org>, Jiri Benc <jbenc@suse.cz>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:53527 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932498AbXAWSbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 13:31:39 -0500
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1169575198.2777.37.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-WIiomWNq297cBvah22oy
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-01-23 at 12:59 -0500, Dan Williams wrote:

> I believe it needs to at least support 4 address frames, which usually
> requires firmware changes on fullmac cards, but fully softmac cards
> (atheros, broadcom) probably would not.

.11s also introduces new frame types/subtypes that probably need to be
ACKed which usually the firmware won't do since it doesn't understand
those frame types/subtypes yet.

johannes

--=-WIiomWNq297cBvah22oy
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFtlRP/ETPhpq3jKURAsipAJ9ikP1f060fVwyi1hJ12K1OTwGp5gCePBZ0
cIO1ioHwB9P2hfS/yWDR8O4=
=WN2k
-----END PGP SIGNATURE-----

--=-WIiomWNq297cBvah22oy--

