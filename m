From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 2/8] farsync: Fix confusion about DMA address and buffer
 offset types
Date: Wed, 21 Dec 2011 05:41:39 +0000
Message-ID: <1324446099.2844.191.camel@deadeye>
References: <1324430940.2844.144.camel@deadeye>
	 <1324431172.2844.147.camel@deadeye> <1324431746.2844.161.camel@deadeye>
	 <20111220.234834.1265302793309771407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-bfzBngK6IaUJNVD5lKu+"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:47257 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751348Ab1LUFlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 00:41:45 -0500
In-Reply-To: <20111220.234834.1265302793309771407.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-bfzBngK6IaUJNVD5lKu+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-12-20 at 23:48 -0500, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Wed, 21 Dec 2011 01:42:26 +0000
>=20
> > I accidentally left signing enabled for this one, which I had intended
> > to disable since you've said that patchwork doesn't deal with
> > signatures.  Except this looks OK on patchwork:
> > <http://patchwork.ozlabs.org/patch/132548/>.
> >=20
> > If that also looks OK to you, is there any reason to avoid signing
> > networking patches?
>=20
> What do you mean exactly by "signing".
>=20
> Do you mean simply the "Signed-off-by: " tag, which you should always
> add to your own patches, or something else?

GPG signing.

Ben.

--=20
Ben Hutchings
Humans are not rational beings; they are rationalising beings.

--=-bfzBngK6IaUJNVD5lKu+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATvFxk+e/yOyVhhEJAQqY5g/8DsapaJJtxg651o+Em+HcrTV+EatW9PMe
Y6E46u5cENvuBaiXrQK7NxGcQAolAcOXslUCItqLsbamQU5FAAAlAuxILCkw07Ki
n7BsxBUAoTrdOxMsKMVsTfoGONihbIFG2Pxc7JqzRgXU1euBj2xx+pAqXtEDf5Bu
zq46gqi/qLDAPQYUPZX4Mnai0ztLi7bCUWNfjc9n1cSkDO4Jos573+WZx+VcFfGR
sykquoqaYFLVQFB8pnfOz1XSSg7XCpvuvBmq/uS0YjMbdKQebzO93XovELD90f/e
f/S6U9kaKe/RqMUbD/9NYGfFKuRWyb21MKSWi1/EqJKVxlfeCeMn2fVAwpf5KvJC
b6RfFmPW4iP40EqHKpQHJCcjHezyK+wEZpwOjZOklCxmuanhLdFPugtvA1QQ808Q
ztm/hIElUeLc1fG73HCyWYzDCtm2UVW5orbcVAsDrTRmik4DIJXHPrSYvqOlLoX6
qvxRC88mo3QyBZ7+8j2+r+v9XRDyN4wP6saRkaulFKi63CSXIbbZSahc4B0YshqL
Ll8vzJutCv4kg82BaNtnqRUY6Yjni2tmUaEcQu806WnWA3LSKnYD6nONNuugNWdF
U38wmk4IYaoC+qFMqqAMd086H7ByI6QZKI/Qb2xOEHQzsu+1lZ8zC21GTCE2bgSH
REiE9m2Dslo=
=TPEW
-----END PGP SIGNATURE-----

--=-bfzBngK6IaUJNVD5lKu+--
