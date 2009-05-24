From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [TSO]-Refer to "State of TCP segmentation offload to NIC in
 linux"
Date: Sun, 24 May 2009 14:15:57 +0100
Message-ID: <1243170957.16597.62.camel@deadeye>
References: <AB6488BF71876F4498928F5DDA526168830FB0@ITCGCL02BE.fsoft.fpt.vn>
Reply-To: netdev@vger.kernel.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-Di/6yeIdA9I8IS7t39yq"
Cc: netdev@vger.kernel.org
To: "Nguyen Tuan Huy (G11)" <huynt1@fsoft.com.vn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:44602 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752006AbZEXNQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 May 2009 09:16:00 -0400
In-Reply-To: <AB6488BF71876F4498928F5DDA526168830FB0@ITCGCL02BE.fsoft.fpt.vn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Di/6yeIdA9I8IS7t39yq
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2009-05-24 at 18:38 +0700, Nguyen Tuan Huy (G11) wrote:
> Dear Mr Ben Hutchings,=20
>=20
> =20
>=20
> I have read your answer about question "State of TCP segmentation
> offload to NIC in linux".=20
>=20
> The link is
> http://kerneltrap.org/mailarchive/linux-netdev/2008/5/7/1757954/thread

Please direct your queries to the netdev list, not to me personally.

> I am now writing network device driver that support TSO function. But
> when I send one packet with 64K, then TCP has divided 64K, not passed
> the whole 64K to NIC driver.
[...]

I think you won't see 64K packets for a TCP connection that was just
opened, due to the slow start algorithm.

Ben.

--=20
Ben Hutchings
Teamwork is essential - it allows you to blame someone else.

--=-Di/6yeIdA9I8IS7t39yq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQBKGUh679ZNCRIGYgcRAscUAJoDuWvI7vCntmHfocJeroVlgD9/bQCggHRE
inGnChhejiTCca9Ok3YLvvI=
=edzS
-----END PGP SIGNATURE-----

--=-Di/6yeIdA9I8IS7t39yq--
