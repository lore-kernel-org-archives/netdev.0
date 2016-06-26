From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH ethtool 2/2] ethtool.8.in, ethtool.c: Add myself to authors
 and copyright notices
Date: Sun, 26 Jun 2016 16:48:28 +0100
Message-ID: <20160626154828.GE7555@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="PoUpPrJlcBv0qM6G"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57918 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751662AbcFZPsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2016 11:48:30 -0400
Received: from ben by shadbolt.decadent.org.uk with local (Exim 4.84_2)
	(envelope-from <ben@decadent.org.uk>)
	id 1bHCIO-0008Df-FV
	for netdev@vger.kernel.org; Sun, 26 Jun 2016 16:48:29 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--PoUpPrJlcBv0qM6G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 ethtool.8.in | 3 ++-
 ethtool.c    | 2 ++
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 9dc5e252a1dc..e08c9a714551 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -947,7 +947,8 @@ Scott Feldman,
 Andi Kleen,
 Alexander Duyck,
 Sucheta Chakraborty,
-Jesse Brandeburg.
+Jesse Brandeburg,
+Ben Hutchings.
 .SH AVAILABILITY
 .B ethtool
 is available from
diff --git a/ethtool.c b/ethtool.c
index 093adf735793..4aa476264b3a 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -21,6 +21,8 @@
  * MDI-X set support by Jesse Brandeburg <jesse.brandeburg@intel.com>
  *	Copyright 2012 Intel Corporation
  * vmxnet3 support by Shrikrishna Khare <skhare@vmware.com>
+ * Various features by Ben Hutchings <ben@decadent.org.uk>;
+ *	Copyright 2008-2010, 2013-2016 Ben Hutchings
  *
  * TODO:
  *   * show settings for all devices

--PoUpPrJlcBv0qM6G
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBV2/5TOe/yOyVhhEJAQqG2w/8CuhxosjXdcICDGMfHpvauLd/olnwxDMZ
miNF9Of7GQZkYRfQi9W1YPd3YRWYrDcRS9FLm/eyhmKGDoyHg72xQTzQ8U4VeeCD
wb4phnpPeQILZHCQrYtCAs4fUbBNDLBrVBqVpXXiU1VZIJE3cb25T9EY+LBw8dOz
3tS4D0kk/BFzPJpU2y25/VeguowWrbkbwi3Nn7OOA1wZx+UizeW4vDgPS7YYdv2/
4C+OmJJuXDJ5z7Ni1MgIkI9y/3LS47ZZkotDNWH2l8WWIP1Vp2oirXeUF0g3Sk09
39SVPr9D9punT2lVAnr1paZAgj9aDnaXBQUvHU8J5ivVY6HQqE44ea13s3h/fkhV
KZjuIDn77SOtXPttv3y/ut7ZUdH2gK2LeDE65TA4kyW3kZx3/EVUFcRJnGi2PUDP
p7jfZgXnioxabAUoazU/8FdbdXu3+gXaeSDiZTHTH6E+rc7tju86cgttra7zLHXs
LdYGZIkito2OD8YRidndl+4Tf4ZingLJRvCx+Vmggf4tRdZEcGYTvQo6vBifdFOH
hCzsg2oMqjiLEZeo3QdG/6VWu6LmB/IQr1JfmPPLzhi7DELzlnbKrZUwVIvZ3n2i
NZkbuyOihqn+OCylYFyfM4EaTPwUe9CaJG1MveM2oqNfYNjEX0IABrbypCkxbD1u
JAPIeguLACk=
=0BWl
-----END PGP SIGNATURE-----

--PoUpPrJlcBv0qM6G--
