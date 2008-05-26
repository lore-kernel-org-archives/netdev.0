From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: [PATCH 0/2] MDIO on GPIO support for the fs_enet driver
Date: Mon, 26 May 2008 11:52:37 +0200
Message-ID: <200805261152.37636.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1692576.rq6FsTAGDv";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Scott Wood <scottwood@freescale.com>
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:49455 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751209AbYEZJy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 05:54:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1692576.rq6FsTAGDv
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi everybody,

here is a patch set that adds MDIO on GPIO support. If there are no show=20
stoppers I'd like to see it going into linux-next.

[PATCH 1/2] net: OpenFirmware GPIO based MDIO bitbang driver
[PATCH 2/2] fs_enet: MDIO on GPIO support

=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart1692576.rq6FsTAGDv
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBIOohl8y9gWxC9vpcRAskXAJ0SmI1nAQ7wCwf3mKAN+b+NHvcKlQCfWhfW
xdI59JszkvrWure4zGFXzTY=
=OfZ+
-----END PGP SIGNATURE-----

--nextPart1692576.rq6FsTAGDv--
