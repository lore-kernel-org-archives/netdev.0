From: Ben Hutchings <bhutchings@solarflare.com>
Subject: ethtool 3.4.2 released
Date: Tue, 17 Jul 2012 16:31:42 +0100
Message-ID: <1342539102.2698.4.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-0ipl1eAOkmaDR080i11T"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:60670 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750852Ab2GQPby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 11:31:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-0ipl1eAOkmaDR080i11T
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ethtool version 3.4.2 has been released.  This fixes various bugs.

Home page: https://ftp.kernel.org/pub/software/network/ethtool/
Download link:
https://ftp.kernel.org/pub/software/network/ethtool/ethtool-3.4.2.tar.gz

Release notes:

	* Fix: Fix regression in RX NFC rule insertion for drivers that do
	  not select rule locations (-N/-U option)
	* Fix: Remove bogus error message when changing offload settings
	  on Linux < 2.6.39 (-K option)
	* Fix: Use alternate method to check for VLAN tag offload on Linux
	  < 2.6.37 (-k option)

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.



--=-0ipl1eAOkmaDR080i11T
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQEcBAABCAAGBQJQBYVeAAoJEGkILBsOca60gGkH+gM6nGiP2fDx0t1sH5HPAMxy
xBki8MG3ift77+zEwtqQ6Tsk7FxagL9Llyz6tvy247cfJTLd7MH9hOjosYsuBHvM
MIKrNsCjkGXobuN6SLsn82W9FUGGWNU2K09545rDqTeS+dhsjQVjQNJurPYvsgek
SVeAFAooTRfoNSAxEAY1BwFQfXHPcYO2b9Xje3foZiKLm/cjrUdgRtbgAHQ/Qks7
arIosOaw1m17194yCg8mlDMjjgJ/JVpKCR/6+RQZuDaNN7AUYlxLuoG3BtH5ayTI
IrKVs7eU5Rc9AM9wRI3VfMd44XqLJBxW0zN8hZZFk0tO0PtA6gc4ccTcd5454Gk=
=Zvo2
-----END PGP SIGNATURE-----

--=-0ipl1eAOkmaDR080i11T--
