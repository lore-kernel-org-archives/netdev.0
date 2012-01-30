From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-next 2012-01-30
Date: Mon, 30 Jan 2012 18:20:27 +0000
Message-ID: <1327947627.2595.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-WVBWviAEcVUnSDk4ihja"
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>,
	Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:26004 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752055Ab2A3SUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 13:20:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-WVBWviAEcVUnSDk4ihja
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit 30088a25e9c4dc1f8bd5c48b14a18633441b5481=
:

  Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/git=
/bwh/sfc-next (2012-01-29 16:11:26 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

(commit 06e63c57acbb1df7c35ebe846ae416a8b88dfafa)

These address the review comments on Friday's changes.

Ben.

Ben Hutchings (2):
      sfc: MTD: Leave the DEBUG macro alone
      sfc: Use a more sensible cast in efx_rx_buf_offset()

 drivers/net/ethernet/sfc/mtd.c |    1 -
 drivers/net/ethernet/sfc/rx.c  |    2 +-
 2 files changed, 1 insertions(+), 2 deletions(-)

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


--=-WVBWviAEcVUnSDk4ihja
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABCAAGBQJPJt9rAAoJEGkILBsOca60LxkIALe4L1DqDoVOQmFnsAoPjQty
037J+5Vhp+D54tmzzW11WCaTzxKdXQAxt2GQfir1HeoTMymg3YrmF/cx5a8r2I6M
XV1Pe4Ag7TxmCB0Act+1tfpF4nQYqhlmd7LFzxxZ+RHX0zljTbdqIuhjZ4X+TJzH
C7XoZtpkSuefumBa+FWnVpTyGTiDyFKqaWVZaITShjMCEHEuuZ74xy1XWCtgbicU
uY8Mz12djNEN1gJ+tMf51BambhmsnLXd6WKbHlNu9vBws0V/kIHZ/CvoT31FNbSw
1HVuLfZefwNeydoSyNAvyVQ22tf6a1QdaJNFOPwZtS+6k6tg8y4pYX8fxkgVwlk=
=Y0Ol
-----END PGP SIGNATURE-----

--=-WVBWviAEcVUnSDk4ihja--
