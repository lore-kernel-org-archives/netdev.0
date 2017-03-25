From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH net-next 0/2] Performances improvement for IPv6 Segment
 Routing
Date: Sat, 25 Mar 2017 09:56:03 +0100
Message-ID: <dfafbcb8-ec24-4585-71b2-025aff0d22e5@uclouvain.be>
References: <20170324094627.16796-1-david.lebrun@uclouvain.be>
 <20170324.144805.1899893937234644395.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="BQdKg8Ehh1oFD6TTk9GUQw3CrDvuFLsJQ"
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:50572 "EHLO
        smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750994AbdCYIzp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 04:55:45 -0400
In-Reply-To: <20170324.144805.1899893937234644395.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--BQdKg8Ehh1oFD6TTk9GUQw3CrDvuFLsJQ
Content-Type: multipart/mixed; boundary="REgtE355Kp064FbL0cSSC7kec7EeoMQI6"
From: David Lebrun <david.lebrun@uclouvain.be>
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Message-ID: <dfafbcb8-ec24-4585-71b2-025aff0d22e5@uclouvain.be>
Subject: Re: [PATCH net-next 0/2] Performances improvement for IPv6 Segment
 Routing
References: <20170324094627.16796-1-david.lebrun@uclouvain.be>
 <20170324.144805.1899893937234644395.davem@davemloft.net>
In-Reply-To: <20170324.144805.1899893937234644395.davem@davemloft.net>

--REgtE355Kp064FbL0cSSC7kec7EeoMQI6
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 03/24/2017 10:48 PM, David Miller wrote:
> Series applied, thanks.
>=20
> I think you should make SEG6_IPTUNNEL select DST_CACHE and then remove =
all of
> these ugly ifdefs.

Thanks

Agreed, I'll submit a patch for that :)

David


--REgtE355Kp064FbL0cSSC7kec7EeoMQI6--

--BQdKg8Ehh1oFD6TTk9GUQw3CrDvuFLsJQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iF0EARECAB0WIQT8nTbQ2eQR5sQwCJ+NvOfruxnoAwUCWNYwowAKCRCNvOfruxno
A4iMAJ955p1wtyMAQMolg0vqR2pGTGovVQCbBvEd6g2QSmMV0iXSBRdvBeqyCB0=
=lnI2
-----END PGP SIGNATURE-----

--BQdKg8Ehh1oFD6TTk9GUQw3CrDvuFLsJQ--
