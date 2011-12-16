From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-next 2011-12-16
Date: Fri, 16 Dec 2011 20:10:13 +0000
Message-ID: <1324066213.2798.19.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-vwAkvhUF+YgfoDAL4PyH"
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:26342 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759793Ab1LPUKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 15:10:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-vwAkvhUF+YgfoDAL4PyH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit de93cb2eaffd6d3e44bc738babfac35769d79720=
:

  vlan: static functions (2011-12-14 02:39:30 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

(commit 70350b0685a370164ed8912835bd7109927c8781)

Ben Hutchings (3):
      MAINTAINERS: Update sfc maintainers
      sfc: Remove device ID macros only used once
      sfc: Use skb_fill_page_desc() to simplify passing of page buffers to =
GRO

 MAINTAINERS                    |    1 -
 drivers/net/ethernet/sfc/efx.c |    4 ++--
 drivers/net/ethernet/sfc/efx.h |    4 ----
 drivers/net/ethernet/sfc/rx.c  |    7 ++-----
 4 files changed, 4 insertions(+), 12 deletions(-)

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--=-vwAkvhUF+YgfoDAL4PyH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABCAAGBQJO66WiAAoJEGkILBsOca60sA4H/2iaWlep53DRgWOmQxkVaPfD
URifiHZsWj5IE4SsAHU3pyNCcbxu+rsMVGx6ssNgpkWJ6YPx98Va9CDpNZ4uG0wc
PnFkqZdM0dQMgwk2aJC7QxAZCLH2/ZgvqK7pumiK4OaayttvwCtLcxqb/h1wyJej
HoETHNO3vG2v7WsrtAsKAhKVYtNAxGG5+EPKw76LUvhw2jgfBjSyGAtQBPybbKn+
Zi87bEZQSx5SQGUvc5XFYxYo0QmIiK9feSJc5mfxafIbo6uPaVW4Go9CmNLp8nr4
C1QZv0WK5suqYtTbgBfGdXVLFmgTyRl12twGHdc/eivbBk8sq5tmIXIL4vSfOZw=
=om7m
-----END PGP SIGNATURE-----

--=-vwAkvhUF+YgfoDAL4PyH--
