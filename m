From: William Dauchy <william@gandi.net>
Subject: Re: [RFC PATCH 00/24] TRILL implementation
Date: Wed, 24 Sep 2014 18:54:47 +0200
Message-ID: <20140924165447.GG27183@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
 <20140924094422.2e710ead@urahara>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="8bBEDOJVaa9YlTAt"
Cc: Ahmed Amamou <ahmed@gandi.net>, netdev@vger.kernel.org,
	william@gandi.net, f.cachereul@alphalink.fr
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:45985 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753013AbaIXQyw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 12:54:52 -0400
Content-Disposition: inline
In-Reply-To: <20140924094422.2e710ead@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--8bBEDOJVaa9YlTAt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sep24 09:44, Stephen Hemminger wrote:
> Is this patch series bisectable? does it build at each step?

it should be the case but we will double check that.

> Also, it seems when you build with trill you lose normal bridge functiona=
lity.
> Whether kernel is doing bridge or rbridge has to be a runtime (not compil=
e time)
> choice on a per-bridge basis.

The normal bridge functionnality are still ok until TRILL is not
enabled.

--=20
William

--8bBEDOJVaa9YlTAt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlQi91cACgkQ1I6eqOUidQE7/gCcCKWORk9najRvvdcooeokfqdL
5vgAoIeBv3LjTZRXcPHNMs4w6MvKDY81
=Epal
-----END PGP SIGNATURE-----

--8bBEDOJVaa9YlTAt--
