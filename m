From: Marcus Better <marcus@better.se>
Subject: Re: rtl8139: NETDEV WATCHDOG: eth0: transmit timed out
Date: Mon, 10 Jul 2006 15:17:10 +0200
Message-ID: <44B25356.4050006@better.se>
References: <e82qhq$4v0$1@sea.gmane.org>	<20060630211604.GA5302@electric-eye.fr.zoreil.com> <44AE8CBB.4070409@better.se> <44AFDA3B.6020904@tungstengraphics.com> <44B0AED8.3040604@better.se> <44B0B17D.10803@tungstengraphics.com> <44B24FF6.5060102@better.se> <44B251C5.6060209@tungstengraphics.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig78A2E77F3FBA82E8D5A333BC"
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	dri-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxfep01.bredband.com ([195.54.107.70]:44227 "EHLO
	mxfep01.bredband.com") by vger.kernel.org with ESMTP
	id S1751275AbWGJNRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 09:17:22 -0400
To: =?ISO-8859-1?Q?Thomas_Hellstr=F6m?= <thomas@tungstengraphics.com>
In-Reply-To: <44B251C5.6060209@tungstengraphics.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig78A2E77F3FBA82E8D5A333BC
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Thomas Hellstr=F6m wrote:
>>> Does the "noirqdebug" option fix the problem?

>> Yes... but it breaks switching to a text console.

> Are you _sure_ these are related?

Yes. (I tried a few times and it always crashed, whereas without
noirqdebug I've switched mode successfully hundreds of times.)

Without the i915 module both network and console switching work.

Marcus



--------------enig78A2E77F3FBA82E8D5A333BC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD8DBQFEslNZXjXn6TzcAQkRArqUAKDY+jMiUbPjLVjnX2CB73JFZ4/AfQCfRtMt
HYT+jFYZJSKDtkaFTPTmjY8=
=6Yyy
-----END PGP SIGNATURE-----

--------------enig78A2E77F3FBA82E8D5A333BC--
