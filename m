From: Marcus Better <marcus@better.se>
Subject: Re: rtl8139: NETDEV WATCHDOG: eth0: transmit timed out
Date: Mon, 10 Jul 2006 15:02:46 +0200
Message-ID: <44B24FF6.5060102@better.se>
References: <e82qhq$4v0$1@sea.gmane.org>	<20060630211604.GA5302@electric-eye.fr.zoreil.com> <44AE8CBB.4070409@better.se> <44AFDA3B.6020904@tungstengraphics.com> <44B0AED8.3040604@better.se> <44B0B17D.10803@tungstengraphics.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE7A592EA15D38FD5AE4C0B36"
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Dave Airlie <airlied@linux.ie>, netdev@vger.kernel.org,
	dri-devel@lists.sourceforge.net,
	Alan Hourihane <alanh@tungstengraphics.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxfep02.bredband.com ([195.54.107.73]:57034 "EHLO
	mxfep02.bredband.com") by vger.kernel.org with ESMTP
	id S1161061AbWGJNC6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 09:02:58 -0400
To: =?ISO-8859-1?Q?Thomas_Hellstr=F6m?= <thomas@tungstengraphics.com>
In-Reply-To: <44B0B17D.10803@tungstengraphics.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE7A592EA15D38FD5AE4C0B36
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Thomas Hellstr=F6m wrote:
> Does the "noirqdebug" option fix the problem?

Yes... but it breaks switching to a text console. I get an interesting
"fluid" effect on the screen (a bright static pattern), and the keyboard
locks up.

Marcus



--------------enigE7A592EA15D38FD5AE4C0B36
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD8DBQFEsk/2XjXn6TzcAQkRAsj1AJ9U8dQyjOsXJLKhGTJmuFXxz20obwCgx004
qBJbZdallj55y6DHFQeyWQU=
=1DKU
-----END PGP SIGNATURE-----

--------------enigE7A592EA15D38FD5AE4C0B36--
