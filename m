From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: TCP stalls in current git, possibly splice related
Date: Fri, 13 Jul 2007 12:02:45 +0200
Message-ID: <1184320965.30334.2.camel@johannes.berg>
References: <Line.LNX.4.64.0707121608100.10773@d.namei>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-WCDPwT1yqHPBHru0go36"
Cc: Jens Axboe <jens.axboe@oracle.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:54389 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752361AbXGMKFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 06:05:18 -0400
In-Reply-To: <Line.LNX.4.64.0707121608100.10773@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-WCDPwT1yqHPBHru0go36
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-07-12 at 16:12 -0400, James Morris wrote:
> I'm seeing TCP connection stalls with current git, and a bisect found the=
=20
> following as a possible cause:

I'm also seeing stalls with synergy.

johannes

--=-WCDPwT1yqHPBHru0go36
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGl03E/ETPhpq3jKURAmOPAKCJhdBMdcoLwQF3n0u+Ac7BWsJl5QCfQbv9
6njuxZ9XmiMXn8zy5pYByus=
=lCZz
-----END PGP SIGNATURE-----

--=-WCDPwT1yqHPBHru0go36--

