From: Ben Hutchings <bhutchings@solarflare.com>
Subject: ethtool 2.6.39 released
Date: Wed, 01 Jun 2011 23:52:48 +0100
Message-ID: <1306968768.2758.55.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256"; protocol="application/pgp-signature"; boundary="=-Cno0flWYLCPxMyTYbuAH"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:54210 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755855Ab1FAWwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 18:52:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--=-Cno0flWYLCPxMyTYbuAH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ethtool version 2.6.39 has been released.

Home page: https://ftp.kernel.org/pub/software/network/ethtool/
Download link:
https://ftp.kernel.org/pub/software/network/ethtool/ethtool-2.6.39.tar.gz

Release notes:

	* Feature: Report some driver features (-i option)
	* Doc: Remove misleading 'Auto' advertising mask from manual page
	* Doc: Improve table formatting on manual page, using tbl
	* Doc: Remove initial blank page in printed manual page
	* Doc: Fix line-wrapping of options
	* Feature: Add support for ESP as a separate protocol from AH
	  (-n, -N, -u and -U options)
	* Cleanup: Remove support for showing RX n-tuple settings
	  (-u option), which was never implemented correctly in the kernel
	* Feature: Add support for RX network flow classifier (NFC)
	  (-u and -U options)
	* Feature: Add support for e1000 M88 PHY registers (-d option)
	* Cleanup: Change bug-address to netdev

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.




--=-Cno0flWYLCPxMyTYbuAH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABCAAGBQJN5sK4AAoJEGkILBsOca60M+QH/j/gIyHSKJXjFALKOrZ9F0aY
TYiTda1B6aY8Msl9Vus74hyvKwetgAi84+teHcbTXMCREQMeiPh5ZCIdmJ1cz8KP
VwjaGNRvTLxa/llgglMMvbBnHYph45apyqpg1oo3bd0V2D4N72FKgCAlnfJhDYfK
HpkaHfTQ21MMRmWSKGgjxZf8cNhJKN+R8N3eXN6BC3zg5L0UWzd8JntXYqrtjZPt
d4ZlGtfUHb254etV0TR3vL987UmBW/Lr8yxAjHAOZkxnjKAuOredU+ULsUbUlh/k
gt6WoTMOKbpruw+w2M8blJNWu/cLKO5ez6sRuyy9WCFN8fFS8ep9rnPVhm+q8tg=
=0NzS
-----END PGP SIGNATURE-----

--=-Cno0flWYLCPxMyTYbuAH--

