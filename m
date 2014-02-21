From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH 00/10] pull request net: batman-adv 2014-02-17
Date: Fri, 21 Feb 2014 08:47:20 +0100
Message-ID: <53070488.2020303@meshcoding.com>
References: <1392670129-2498-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="88EFkjNOc8xD17cIUKaKs5CNvemkcHIVd"
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:22104 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752283AbaBUHs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 02:48:56 -0500
In-Reply-To: <1392670129-2498-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--88EFkjNOc8xD17cIUKaKs5CNvemkcHIVd
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 17/02/14 21:48, Antonio Quartulli wrote:
> Hello David,
>=20
> here you have a pull request intended for net/linux-3.14 and linux-3.13=
 (please
> take care of queuing these patches for merging in the latter).
>=20

David,

as I asked above, do you think it would be possible to queue this
patchset for inclusion in 3.13.x ?

If you think the patchset is too big, we can safely _exclude_ patches 4,
5, 6 and 9 from sending to stable since they are fixing "potential" error=
s.


Thanks a lot!

--=20
Antonio Quartulli


--88EFkjNOc8xD17cIUKaKs5CNvemkcHIVd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTBwSNAAoJEEKTMo6mOh1VrmUQAJwsCiT95GCGdxQg6hyLW8K8
SwYK2VM+qPiqu4/X0Ra//t+xBgh6PV2QgStiDxYjHlNmu0AKkfIXzgy2Pa9wA7jG
cUOlk5QcI8X2Ui8yw83gvQ92XRk1eevd91Sj/1/JScLj1VJ0HgjvzqDV5Deo6nfP
cQ7Ftp9xaW+/4NAJ64PFRLQf9zs3nzo8ABFA6LkACnXt9wg9Kqv65anDTfKRFNfF
MYXVj3NMPPeZiqBFJ2ik4miL4p4LzN/Z9bZZ/pwqls/eiU8mcUINMKNWyLIeFRqh
Jdm6MxXWiSgEo58PUa+E+wAE6wLtAuDDII+4arankjO66nK+q2lylap4S65zZH7c
HRRMLltDr4G8nRXYuOcoWCjBiqcsWJX6L9GjOGAwo14KeqIpTAmqiiOtZtKHZp4n
j5cvUFqgpLp/jVxWFsvJ4/zt2kHA5+zyahY+Rkq6AIHXot7Z5QyQB594AzFeclY5
meJYF37ITy3PLYiVUiE8KToiJ7KKk305b99J1kVR6ontakoHftWowhMeDTonZc71
so9CvP3KMk+7Mrq7b15ZdCHtHLEedtE5neLhp8d5CdfccDNYqhomb7eG4N6UWCng
Q74tIMSjFv2+PZgsGIIOMK/atP//vdMjK4VN/DI4bDL99N9ogWfxPrJXKwOWjoeJ
oo0otaJYmw3dYYwfRZ6U
=qyo4
-----END PGP SIGNATURE-----

--88EFkjNOc8xD17cIUKaKs5CNvemkcHIVd--
