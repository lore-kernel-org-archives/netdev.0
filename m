From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH V1 net-next] net/fm10k: Avoid double setting of
 NETIF_F_SG for the HW encapsulation feature mask
Date: Tue, 11 Nov 2014 00:25:37 -0800
Message-ID: <1415694337.2466.96.camel@jtkirshe-mobl>
References: <1415520822-11922-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-v+BpED+GbWyGT8Ss2Rj4"
Cc: netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:32618 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752847AbaKKI0O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2014 03:26:14 -0500
In-Reply-To: <1415520822-11922-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-v+BpED+GbWyGT8Ss2Rj4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-11-09 at 10:13 +0200, Or Gerlitz wrote:
> The networking core does it for the driver during registration time.
>=20
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>=20
> changes from v0:
>  - set alignment to be per the request of Matthew Vick
>=20
>=20
>  drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |   13 ++++++-------
>  1 files changed, 6 insertions(+), 7 deletions(-)

Thanks Or, I have added your patch to my queue.

--=-v+BpED+GbWyGT8Ss2Rj4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUYcgBAAoJEOVv75VaS+3OC98P/0rQ4fvNEzscgLNe4jq74ELt
k521n0cdRXlOnPi+YHZzVclO72LUtlhPDdQkJ5c6XRp/qX26jHh1WVJHcZPo1Ed2
EHvahHhb0HwR4t0n4V9NLt3RfokJ4TzWkzDqIySEgztNCMJlLHqd0Brl99Dv8h75
iMzo8iXS3Wtc05T7cn/hCHln24e07/tD4J5+3O1O5gjN/9Z1zvAFWyOKWJg8Vz2l
HUJ7wX5HSypI3SbitftAj4aH92nsqvTejpl6GhJc8gsQQy6FogdpI5s48fJzzXjl
KRaHZLxu8mqNxJAGJMJj++wTQenz2jma0wxGd0lpIRjmhFbnnZYUmLNj+92rsmSB
xT3Z/hv9F93TagiubfybGOC9sY2ZQAFGz7uPN7YNUd5EoTKf3FIkuN+Lxj6qWGnX
r8HIJ7kTPxxFbsdjmfVD6wOw/81rwnhTti3tzmlUE+wcYIQw5lJj5pmBewHG+8T/
0iUmj22RCJd58dSf2bTTaLjvSunWw3gpV83fjFqdkAdpfIVUz7qZNo5yvMlGsjFy
urAWOqL0kwdlm129ZipOA4hsVjYrwZZp65U5mFG5cy064+d5VF0pqSZNYjf4GkbJ
TGxQADA89dRZ9yAVIA4RN7BT3QIZmSswbgX+8pUoiXXoHr4A2/Uv5DcClvcpaiRN
cwqjxEPK1hmdSD39OCG5
=kLf+
-----END PGP SIGNATURE-----

--=-v+BpED+GbWyGT8Ss2Rj4--
