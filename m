From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 0/8] ISDN patches for net-next
Date: Tue, 08 May 2012 02:24:17 +0200
Message-ID: <4FA867B1.9080003@imap.cc>
References: <20120425-patch-gigaset-00.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigB038A42B5BBE08B5F883BB2A"
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:53964 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932297Ab2EHAYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2012 20:24:20 -0400
In-Reply-To: <20120425-patch-gigaset-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigB038A42B5BBE08B5F883BB2A
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

On 26.04.2012 01:02, /me wrote:
> here's a series of eight patches to the Kernel CAPI subsystem and
> the Gigaset driver. Please consider for application to net-next.
> The first three should also go into -stable and are tagged accordingly.=


Is there anything missing for these to be accepted into net-next?
Or should I just be patient?

Thanks,
Tilman

> Tilman Schmidt (8):
>       isdn/gigaset: ratelimit CAPI message dumps
>       isdn/gigaset: fix CAPI disconnect B3 handling
>       isdn/gigaset: improve error handling querying firmware version
>       isdn/gigaset: fix readability damage=20
>       isdn/gigaset: internal function name cleanup
>       isdn/gigaset: unify function return values
>       isdn/capi: fix readability damage
>       isdn/capi: elliminate capincci_find() in non-middleware case

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enigB038A42B5BBE08B5F883BB2A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.16 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk+oZ7EACgkQQ3+did9BuFvO5ACbBek9NUkMMVP35s0PeAW31yQQ
5rUAoIozr5hIZU4Ou/mC4QpmHUMiw/KF
=QDpW
-----END PGP SIGNATURE-----

--------------enigB038A42B5BBE08B5F883BB2A--
