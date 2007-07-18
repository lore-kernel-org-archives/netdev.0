From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: TCP stalls in current git, possibly splice related
Date: Wed, 18 Jul 2007 12:58:52 +0200
Message-ID: <1184756332.4658.16.camel@johannes.berg>
References: <Line.LNX.4.64.0707121608100.10773@d.namei>
	 <1184320965.30334.2.camel@johannes.berg> <20070713110534.GF5328@kernel.dk>
	 <1184575545.15112.0.camel@johannes.berg> <20070716120247.GG5195@kernel.dk>
	 <1184711770.4658.5.camel@johannes.berg>  <20070718104916.GJ11657@kernel.dk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ntYUhwubXuns1KsevDkt"
Cc: James Morris <jmorris@namei.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:41332 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752289AbXGRK7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 06:59:13 -0400
In-Reply-To: <20070718104916.GJ11657@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ntYUhwubXuns1KsevDkt
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-07-18 at 12:49 +0200, Jens Axboe wrote:

> OK, then we can put splice off the hook at least :-)

:)

> If it's easily reproducible (and it sounds like it), then a git bisect
> might be the easiest way forward.

Yeah, I only need to try to remember when I last *didn't* see the
problem, and hope that my analysis about it being on the receiver side
is correct :)

johannes

--=-ntYUhwubXuns1KsevDkt
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGnfJs/ETPhpq3jKURAlPRAJ4rpsvJR26NcfGcKkiJg9Z4yh4KXACdGCxr
YmJ0z6Lr/pjYFzGL3DO4PRw=
=aKRx
-----END PGP SIGNATURE-----

--=-ntYUhwubXuns1KsevDkt--

