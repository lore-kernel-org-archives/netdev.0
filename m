From: Ben Hutchings <bhutchings@solarflare.com>
Subject: ethtool 2.6.38 released
Date: Tue, 15 Mar 2011 17:45:19 +0000
Message-ID: <1300211119.2758.6.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256"; protocol="application/pgp-signature"; boundary="=-bd3y7DRKr66lT74BtkNi"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12006 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758160Ab1CORpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 13:45:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--=-bd3y7DRKr66lT74BtkNi
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ethtool version 2.6.38 has been released.

Home page: https://ftp.kernel.org/pub/software/network/ethtool/
Download link:
https://ftp.kernel.org/pub/software/network/ethtool/ethtool-2.6.38.tar.gz

Release notes:

	* Doc: Fix spelling and spacing in online help
	* Doc: Update date, version and web site reference in manual page
	* Doc: Fix spelling, capitalisation, consistency and style in
	  manual page
	* Doc: Generalise some references to network devices rather than
	  Ethernet devices
	* Fix: Don't silently ignore speed/duplex when autoneg is on
	* Fix: Report an error (rather than full usage information) if
	  given an unrecognised option
	* Feature: Add --version option

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.



--=-bd3y7DRKr66lT74BtkNi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABCAAGBQJNf6WpAAoJEGkILBsOca60WDQIAKKUKvgupZt5CQDfhUx2IHfj
01xL7DUT0XtSM04fwZz3WCFYnwQgFXbJGqa7vicEpleVMEhUKn7nnp0Y19UmEEeT
NtS/GpYGkB2S/4u3MNmPuGKu38u4rwWPmYlNifTf10yTVd7MLjQTyOpqKaqFmnbW
p8sPjh3zavoApTLbuk7pvh6Pa5ulhDefYZe+sEiy6xcNOAk3v0sRBTnD+zorVYv3
dGa0/+jpQVB7sZb7jkD1vOQWXLdWT3AX8dvqUWLnXLz5HVH8lTrreBMlvbufsfOB
bbMmqY4kCDFbHLmT8WABGYY8MOkB005D3r5zERJF4WHTIebJm3Octr8l5zVs1NU=
=Dnj4
-----END PGP SIGNATURE-----

--=-bd3y7DRKr66lT74BtkNi--

