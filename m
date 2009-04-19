From: Ben Hutchings <ben@decadent.org.uk>
Subject: e1000e NVM mutex contention warnings
Date: Sun, 19 Apr 2009 14:17:04 +0100
Message-ID: <1240147024.3384.20.camel@deadeye.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-3YkZoGBqScvw0QR858wl"
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, 524699@bugs.debian.org,
	netdev@vger.kernel.org
To: David Graham <david.graham@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:38905 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757498AbZDSNRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Apr 2009 09:17:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-3YkZoGBqScvw0QR858wl
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

David,

What's your plan for collecting information about NVM mutex contention
and when do you intend to remove the warnings?  I have to say I find
this way of testing very user-unfriendly and would like to see it gone
as soon as possible.

Ben.


--=-3YkZoGBqScvw0QR858wl
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQBJ6yRP79ZNCRIGYgcRAmfbAKC2BWEPxwvCF/NabrcQzAvz6N3kngCdFDzX
X9j0dntDz0U5Gk/Sq1oWhdE=
=vGgQ
-----END PGP SIGNATURE-----

--=-3YkZoGBqScvw0QR858wl--
