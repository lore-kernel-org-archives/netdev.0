From: Michael Wu <flamingice@sourmilk.net>
Subject: d80211-drivers pull request (week05)
Date: Sat, 3 Feb 2007 03:01:27 -0500
Message-ID: <200702030301.32123.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2025744.r7lz0qS6cz";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Drake <dsd@gentoo.org>,
	Ulrich Kunitz <kune@deine-taler.de>
To: John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:63118 "EHLO
	annwn14.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1946391AbXBCICF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Feb 2007 03:02:05 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2025744.r7lz0qS6cz
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi John,

Please pull
git://git.kernel.org/pub/scm/linux/kernel/git/mwu/d80211-drivers.git
for these patches:

adm8211-week05 branch:
Michael Wu (1):
      adm8211: set MAC address properly

p54-week05 branch:
Michael Wu (3):
      p54: set MAC address properly
      p54usb: silence warnings on BE
      p54pci: make work for big endian

zd1211rw-week05 branch:
Daniel Drake (3):
      zd1211rw-d80211: Generic HMAC initialization
      zd1211rw-d80211: Consistency for address space constants
      zd1211rw-d80211: Remove addressing abstraction

Maxime Austruy (1):
      zd1211rw-d80211: fix potential leak in usb_init

Michael Wu (1):
      zd1211rw-d80211: Support for multicast addresses

Ulrich Kunitz (2):
      zd1211rw-d80211: Fixed array size issue in reset_mode
      zd1211rw-d80211: Reset device in the probe call

Common to all branches:
Michael Wu (1):
      Remove unnecessary includes and SET_MODULE_OWNER

Patches ported from zd1211rw (softmac) now have the original author of the=
=20
patch set as the author in the commit when the "porting" was trivial.

Thanks,
=2DMichael Wu

--nextPart2025744.r7lz0qS6cz
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFxEFcT3Oqt9AH4aERAoOIAKC9kfg8lhamxrE6pVew79n3s9etsgCfWir5
lKMdcIcCQI1HavNN/xZ7CZU=
=pJcE
-----END PGP SIGNATURE-----

--nextPart2025744.r7lz0qS6cz--
