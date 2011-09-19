From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with Linus' tree
Date: Mon, 19 Sep 2011 14:41:20 +1000
Message-ID: <20110919144120.ed99af0f84549069a4a18ad2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__19_Sep_2011_14_41_20_+1000_AXD.K9FXgxVI11UG"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from calzone.tip.net.au ([203.10.76.15]:49353 "EHLO
	calzone.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773Ab1ISEl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 00:41:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Mon__19_Sep_2011_14_41_20_+1000_AXD.K9FXgxVI11UG
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/Kconfig between commit 7756332f5b64 ("pch_gbe: support ML7831
IOH") from Linus' tree and the driver rearrangement patches from the net
tree.

The changes in the commit from Linus' tree don;t affect fucntionality, so
I just used the net tree version.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__19_Sep_2011_14_41_20_+1000_AXD.K9FXgxVI11UG
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOdsfwAAoJEDMEi1NhKgbsi1EH/3H+TjAqBIbWD2Zb+YxtXkhW
7rEsVm4/vf1DhLJaCM7bLjpZQL0YKc1fOaHoVo3KHosesHi5uD8HnrvuaKI8x9Og
iJAjOV2r9vFpTSCYMxzOj71Zx3SBR6up192q748D2gZL+yJc/PEOwefxB8f7zl7F
vsGzdYGPM8OKNpXIIMelp3RpRwv90Pg7G/PmEFEITv0bUha3NV4A0LKRZYqGNClx
X6qmdW0xycOFqf2RpWVfnBbzPIEVpIC5jiiMd/Dy5gLSUhEYBM8O7M9bM93QNRAD
xAdtW6tVo9avAtrJD4MGLCc88ItLLstKQ1lYAJZu3fhffnqacXXXU/cPhSG4ESg=
=eEn4
-----END PGP SIGNATURE-----

--Signature=_Mon__19_Sep_2011_14_41_20_+1000_AXD.K9FXgxVI11UG--
