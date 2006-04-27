From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 26/32] rt2x00: Move all USB and PCI common data into seperate headers
Date: Fri, 28 Apr 2006 00:03:16 +0200
Message-ID: <200604280003.17311.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6102534.G7P62Lqag1";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.190]:44908 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751794AbWD0WCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:02:17 -0400
Received: by nproxy.gmail.com with SMTP id x30so1388639nfb
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:02:17 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart6102534.G7P62Lqag1
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

From: Ivo van Doorn <IvDoorn@gmail.com>

Now that rt2x00_pci and rt2x00_usb structures in the various
headers are generic enough, add 2 header files rt2x00pci and rt2x00usb
and make them contain all common information of the PCI or USB modules.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

Available on server:

http://mendiosus.nl/rt2x00/rt2x00-26-dev.diff

--nextPart6102534.G7P62Lqag1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+laqndE37Em0gRAtP6AJ4s63cSBC5Ay2rqsspct6d95AERTwCfUxgI
j25Cco+vEc9hWakP+2yzG0M=
=5bjY
-----END PGP SIGNATURE-----

--nextPart6102534.G7P62Lqag1--
