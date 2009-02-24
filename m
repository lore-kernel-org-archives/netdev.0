From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: Re: 2.6.29-rc6: Reported regressions 2.6.27 -> 2.6.28
Date: Tue, 24 Feb 2009 17:05:26 +0100
Message-ID: <200902241705.33271.eike-kernel@sf-tec.de>
References: <HFSEX4uppGO.A.JSG.2yzoJB@chimera>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3955075.jOvQHGNNMs";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sf-mail.de ([62.27.20.61]:59717 "EHLO mail.sf-mail.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752534AbZBXQFo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2009 11:05:44 -0500
In-Reply-To: <HFSEX4uppGO.A.JSG.2yzoJB@chimera>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart3955075.jOvQHGNNMs
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Rafael J. Wysocki wrote:

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12500
> Subject		: r8169: NETDEV WATCHDOG: eth0 (r8169): transmit timed out
> Submitter	: Justin Piszcz <jpiszcz@lucidpixels.com>
> Date		: 2009-01-13 21:19 (42 days old)
> References	: http://marc.info/?l=3Dlinux-kernel&m=3D123188160811322&w=3D4
> Handled-By	: Francois Romieu <romieu@fr.zoreil.com>

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12411
> Subject		: 2.6.28: BUG in r8169
> Submitter	: Andrey Vul <andrey.vul@gmail.com>
> Date		: 2008-12-31 18:37 (55 days old)
> References	: http://marc.info/?l=3Dlinux-kernel&m=3D123074869611409&w=3D4

=46rancois,

would you agree to mark both as dupe of #10109? These problems have been th=
ere=20
for a year now, that is nothing new.

Eike (shortening CC list)

--nextPart3955075.jOvQHGNNMs
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)

iEYEABECAAYFAkmkGs0ACgkQXKSJPmm5/E5vgwCfSvMk0kNOZBQ/TF0Nbjeaw9Ov
WBcAni50Vemrd+QhCCyQuzfY1otnZBA5
=+RhC
-----END PGP SIGNATURE-----

--nextPart3955075.jOvQHGNNMs--
