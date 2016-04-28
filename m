From: Antonio Quartulli <a@unstable.cc>
Subject: Re: pull request [net]: batman-adv-0160426
Date: Fri, 29 Apr 2016 07:58:10 +0800
Message-ID: <20160428235810.GN11201__18669.7778445252$1461887937$gmane$org@prodigo.lan>
References: <1461641239-7097-1-git-send-email-a@unstable.cc>
 <20160428.164351.907536352207317310.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="rPgHZmYkQ+bUEpVC"
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:1447 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751801AbcD1X6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2016 19:58:43 -0400
Content-Disposition: inline
In-Reply-To: <20160428.164351.907536352207317310.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--rPgHZmYkQ+bUEpVC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 28, 2016 at 04:43:51PM -0400, David Miller wrote:
> > Patch 2 and 3 have no "Fixes:" tag because the offending commits date
> > back to when batman-adv was not yet officially in the net tree.
>=20
> This is not correct.  Instead, in the future, you should provide a
> Fixes: tag that indicates the commit that merged batman-adv into the
> upstream tree initially.

makes sense. Thanks for the suggestion!

--=20
Antonio Quartulli

--rPgHZmYkQ+bUEpVC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXIqOSAAoJEJ4aZjxxc6bKrEIQAK+ZmZ2bAhChgX5Z9lVauCxl
qiaGNTlA4h+i6CDFVljYz7R3nxJh8JK4Qw7uUWdlmir/2BOE4w8TeWUsqFS3JIaR
DHYjCwk2nyrCeqYTe8PsbQOQIB1qCE+Bn+TqpCdtplX9mmDJhTI58AhgTc4VzgkX
UsRIzwNXfZ9nN0KAsNrrCgn3ZzFdWvEHL9k7/lFO1rzjEM+6M7kUlnrZ+zESi0DD
W1/j4qbs1M95u7goJEhD/u643AC1V+3HWFPDNVBaNlVLlOyvL6/gNURXt5v7OTHW
M8N3U32iohzZ/lbXvhZZMNCHynOLntB3NLTpx9qPnnf0l0JLXn0VQrEVOhFhhovH
gaj0zc6k4fJwjtEbQa8K8iIznhQ+XNOoYfInbX91BlSoE+47/zvscskDY9dJOxRQ
rzlnUi3xJ5KaABhxzRvPidU6R+tcH34g4dQiMToTlAI2C+oGhxee4/byCaOSOKXi
g2udQSaeOEhTf+XadtoA47D1UEzw4dTnooO7o9rvkn7Xf4nvgBUZFXR42Nn4JPLW
VJYXmdikx2xpO8HBY5bOBvZlCJbKzgN75+8v5ULkzTEGM0xCqWd1iMhQ6gGysJch
VRYsV7GyLKPPVN0BclVru1rMNtmj29jRMJ1zWqFt/qbvk4Ohe6UXtsV55AZmyhER
ADAWPaXbuKPiR7/uY97X
=yBPo
-----END PGP SIGNATURE-----

--rPgHZmYkQ+bUEpVC--
