From: Jan Kiszka <jan.kiszka@web.de>
Subject: Re: [PATCH 30/31] CAPI: Remove experimental tag from middleware feature
Date: Sat, 23 Jan 2010 14:13:47 +0100
Message-ID: <4B5AF60B.3070100@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>	<9dd553d458def04edc7790f0320ffdf1f8909aa5.1264201408.git.jan.kiszka@web.de> <20100123122327.7d2622f4@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig80C66DB2AAC9C886D9C69426"
Cc: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:60406 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755204Ab0AWNNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 08:13:49 -0500
In-Reply-To: <20100123122327.7d2622f4@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig80C66DB2AAC9C886D9C69426
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Alan Cox wrote:
> On Sun, 10 Jan 2010 14:12:41 +0100
> Jan Kiszka <jan.kiszka@web.de> wrote:
>=20
>> Despite all its bugs, the middleware support of our CAPI stack was
>> already in use for many, many moons. And after going through its code,=

>> fixing all issues I found, I feel it deserves to officially become a
>> non-experimental feature.
>=20
> Slightly NAK this - I'm really glad to see the work getting done, but
> until it uses krefs properly for the tty references I'd say it is
> experimental still.
>=20
> I'd like to help you sort out the tty krefs stuff, using tty_port and s=
o
> on and get that wart fixed too.

Will look into to this. Some good starting point or reference driver for =
me?

Thanks,
Jan


--------------enig80C66DB2AAC9C886D9C69426
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAkta9gsACgkQitSsb3rl5xQqLwCg1zvCDMWoH8LFHgi0znBYjujS
guAAmgNAu0qQlTCXsggmv6whJBn2zXxT
=7QLn
-----END PGP SIGNATURE-----

--------------enig80C66DB2AAC9C886D9C69426--
