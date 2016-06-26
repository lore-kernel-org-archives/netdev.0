From: Ben Hutchings <ben@decadent.org.uk>
Subject: ethtool 4.6 released
Date: Sun, 26 Jun 2016 17:59:32 +0200
Message-ID: <1466956772.2551.6.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-tBUyx/dLOLNcjeHSxpst"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57989 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751505AbcFZP7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2016 11:59:45 -0400
Received: from [137.158.23.48] (helo=deadeye)
	by shadbolt.decadent.org.uk with esmtps (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
	(Exim 4.84_2)
	(envelope-from <ben@decadent.org.uk>)
	id 1bHCTH-0000IN-6Q
	for netdev@vger.kernel.org; Sun, 26 Jun 2016 16:59:43 +0100
Received: from ben by deadeye with local (Exim 4.87)
	(envelope-from <ben@decadent.org.uk>)
	id 1bHCTF-0006CV-GK
	for netdev@vger.kernel.org; Sun, 26 Jun 2016 17:59:41 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-tBUyx/dLOLNcjeHSxpst
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ethtool version 4.6 has been released.

Home page: https://www.kernel.org/pub/software/network/ethtool/
Download link:
https://www.kernel.org/pub/software/network/ethtool/ethtool-4.6.tar.xz

Release notes:

	* Feature: Support register dump on Intel X550 NICs (-d option)
	* Fix: Correct some reported register offsets on Intel 10GbE NICs
	  (-d option)
	* Feature: Add IPv6 support to NFC (-n, -N, -u and -U options)
	* Feature: Add support for ETHTOOL_xLINKSETTINGS ioctls (no option
	  and -s option)
	* Feature: Use netlink socket when AF_INET not available

Ben.

--=20

Ben Hutchings
compatible: Gracefully accepts erroneous data from any source

--=-tBUyx/dLOLNcjeHSxpst
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXb/vlAAoJEOe/yOyVhhEJIYEQAMQPb9N9yZKVqCgLqeRYpXo2
cQURvhyGvj5oex6rSsp7ZbaZ1TVuQ2nmMdug7iVQ1XI30A9FXP910ZQWGQ72MX88
NQhjUmFI+YXuI5GzsOCi65MVUJyVRCmrJkC51yXcY0T8sahlZNskk1Z6Zgc7CJyJ
U5qd7cqLgWmOo0YbKo+nLMCqJV69MSRE8HFhvviljEXJRU0J9pWt7U4p9r5iZHCB
imMOEwMi1KhZ05Pv8sYrUJLiyNjFDBEhdtFmtaW5hyJvymJH1SV4H19Usk5s6Mfk
2NCfyNap+VkSPoOxynK/dco5r5JaotfeK6sTsV2dmvUj+x0+Bagm7dcbKw88I7BF
slGcQ1NWw0inaW142Ij6RnrtwVyhbwwIVqd24rnMc/LkZ9jNIRxKuuRCoHAI3S51
0Tu48r10ddFIzeNVO7bDsqSO20Tms2Ly60mNh1BoUzl4N4lBCH+5peP7BAHqzI3G
3gvo50usI9/TtVZA+ojkC1qJ4sArlR1RHN1I+k+hMLsp47WQs3pNs/B5I7itjma3
EtrG4l2wJsnhmFEsTMjns84+Zopw7MO/aQoLPJnNwSKJvcL87p4rgHeQtTo54+bu
BNlCAhbTKvToaOSOZOL7x/AqyPnhAdMVmY8IWIu2IDmiaFTOKFffhtI4yEqSaTJy
QUrYwcj8vyS8IAMELXE2
=WutV
-----END PGP SIGNATURE-----

--=-tBUyx/dLOLNcjeHSxpst--
