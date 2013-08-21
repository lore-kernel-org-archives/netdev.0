From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Pull request: sfc 2013-08-21
Date: Thu, 22 Aug 2013 00:52:59 +0100
Message-ID: <1377129179.634.8.camel@bwh-desktop.uk.level5networks.com>
References: <1377128568.634.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-mBuocwJdooqPyjlAXw/g"
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:33641 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753309Ab3HUXxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 19:53:07 -0400
In-Reply-To: <1377128568.634.5.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-mBuocwJdooqPyjlAXw/g
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

[Re-sending with the proper cc's and a signature.]

The following changes since commit 0f7dd1aa8f959216f1faa71513b9d3c1a9065e5a=
:

  Merge tag 'clk-fixes-for-linus' of git://git.linaro.org/people/mturquette=
/linux (2013-08-16 10:00:18 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc.git sfc-3.11

for you to fetch changes up to f3851b0acc5a75bd33c6d344a2e4f920e1622ff0:

  sfc: Fix lookup of default RX MAC filters when steered using ethtool (201=
3-08-21 14:18:12 +0100)

Just a single fix for 3.11 (and 3.10-stable).

Ben.

----------------------------------------------------------------
Ben Hutchings (1):
      sfc: Fix lookup of default RX MAC filters when steered using ethtool

 drivers/net/ethernet/sfc/filter.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--=-mBuocwJdooqPyjlAXw/g
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQEcBAABCAAGBQJSFVLbAAoJEGkILBsOca60Hf8H/jcAS1JHvFs+dxhzPFcySexd
R7iX1pTz0cK3Y17DIq3yoh5uZQIm65Kez++ojNIJOtYLqoMmK3SMt4IUISDC1L/z
Owa/b0h60A22n05FoirQeaoIr7X842h8DKHVuXAiM2HUpttHNIhCD1lLrurTglj3
kSMaB8eWfXxI1oMZJ+6YLWvAFmXWObCPbKBotwL4MPLEsAjOXWFlMGhSUTcHkOuP
xKH3nJljSORAIBjk4nInCQES582rPcOorS3Q+ptmOj0qPEZI9mOq/02LTt1CPvHq
wG4BL07Gz4gTmBwZOprnCGdbQVeaRoYPz5xfX+7XDHCs1PymxCW+Xt2bWKueAgY=
=IBNb
-----END PGP SIGNATURE-----

--=-mBuocwJdooqPyjlAXw/g--
