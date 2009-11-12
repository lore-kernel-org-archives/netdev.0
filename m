From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH 0/4] vbus: venet macvlan support
Date: Thu, 12 Nov 2009 10:44:37 -0500
Message-ID: <4AFC2D65.9040903@gmail.com>
References: <20091110222632.24100.14884.stgit@mimic.site>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig75BEB90EED3DC6DAD9C707F9"
Cc: alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, kaber@trash.net, arnd@arndb.de,
	bridge@lists.linux-foundation.org, evb@yahoogroups.com,
	netdev@vger.kernel.org
To: Patrick Mullaney <pmullaney@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:44282 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753228AbZKLPoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 10:44:38 -0500
In-Reply-To: <20091110222632.24100.14884.stgit@mimic.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig75BEB90EED3DC6DAD9C707F9
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Patrick Mullaney wrote:
> (Applies to alacrityvm.git/master:34534534)
>=20
> This patchset implements a vbus venet device with a
> macvlan backend.

Thanks Pat, applied.

If possible, please submit a patch for the userspace side "-net
venet-macvlan[,macaddr][,lower-devname]" feature ASAP and I will merge
that as well.

-Greg


--------------enig75BEB90EED3DC6DAD9C707F9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkr8LWUACgkQP5K2CMvXmqGRaQCgiC071fN0Uw8BceZbqTkXPYTk
KX4Anjl1Gbm/ME8ATSrlvBEmr0FckhFM
=DijE
-----END PGP SIGNATURE-----

--------------enig75BEB90EED3DC6DAD9C707F9--
