From: William Dauchy <william@gandi.net>
Subject: Re: [RFC PATCH 03/24] net: rbridge: Add RBridge structure
Date: Wed, 24 Sep 2014 18:55:25 +0200
Message-ID: <20140924165525.GH27183@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
 <1411573940-14079-4-git-send-email-ahmed@gandi.net>
 <20140924094048.05fbd3ea@urahara>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="e5bfZ/T2xnjpUIbw"
Cc: Ahmed Amamou <ahmed@gandi.net>, netdev@vger.kernel.org,
	william@gandi.net, f.cachereul@alphalink.fr,
	Kamel Haddadou <kamel@gandi.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:41928 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752736AbaIXQzb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 12:55:31 -0400
Content-Disposition: inline
In-Reply-To: <20140924094048.05fbd3ea@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--e5bfZ/T2xnjpUIbw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sep24 09:40, Stephen Hemminger wrote:
> Be consistent, always use kernel types (u16) not stdint types (uint16_t)

true, we'll fix that
--=20
William

--e5bfZ/T2xnjpUIbw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlQi930ACgkQ1I6eqOUidQG3zgCgvFrfvcqnmHv1tiTuA4BcDHYo
E1EAoKauQucSu7e6r2P6m5y558ogtiHK
=VVnC
-----END PGP SIGNATURE-----

--e5bfZ/T2xnjpUIbw--
