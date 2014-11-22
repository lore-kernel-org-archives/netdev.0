From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 01/17] i40e: Remove unneeded break statement
Date: Fri, 21 Nov 2014 21:58:43 -0800
Message-ID: <1416635923.2280.110.camel@jtkirshe-mobl>
References: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416635708-4765-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ceULwQ+2DH4Pop0Rpv+F"
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37548 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750711AbaKVF6o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2014 00:58:44 -0500
In-Reply-To: <1416635708-4765-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ceULwQ+2DH4Pop0Rpv+F
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-11-21 at 21:54 -0800, Jeff Kirsher wrote:
> From: Shannon Nelson <shannon.nelson@intel.com>
>=20
> This case statement is empty and the fall through just breaks out
> so remove the break and let it fall through to break out.
>=20
> Change-ID: I1b5ba9870d5245ca80bfca6e7f5f089e2eb8ccb0
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_main.c | 2 --
>  1 file changed, 2 deletions(-)

Disregard this patch, I fixed a mis-spelled word in the patch, but
forgot to cleanup (ie remove) this patch from the group of patches to be
sent.  I have already sent out the "fixed" patch in the series.

--=-ceULwQ+2DH4Pop0Rpv+F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUcCYTAAoJEOVv75VaS+3OjAEQAJveykcvK8vdmgm8XIP3rHgc
JL2TMpRIUPvFAuhgBIYYdXC0Un6beGjwSlpyieFRXiTw8UYnAvkaeEPwgH+tKsX+
WyCYYDR4P2vl72cOvhuxjuVGElc0RsFHPfbDZXC8acHONPiR4OwP70tCDSDZj2Dx
H9AjGzhcJ05PeDHpUXPe9XD/4NMHhRig369cF8qR1ecPdgdPlLtrAruba5XjCcWg
Xq79AdDUQ7dagQe0i4ngpwHoJ7KgVFvdY4oTQMLnmC72uS7phede2xk7vzyb5kDS
el7Uc2B1JvMi9H93wE0G6g63a3mWlbxYTFCQDDvTZNwMpii3WVN3y6RB5tjtJRp/
aUCdw0arWY8KhBy8POiJvQv2ixO6oI2xTjp1/RV9NbPFwLP3I15QO4qhI6ix/gRt
p0Rh5fT3jofFo6JqACvVSX5HQNbqO4ENEe1RBGFPOBQcMUBMKnwfMvXrsr7sIf5u
q/MqxQsc8569LVgofZfoZl7y4X/7Ly6DvenyUNdkGVNm1eaQX+GuLn1m7mcKtPiX
382Ct0OXZe8LaJlImWyweEwWLvO/wCfeu9QRqHftl2dDL+NiTTamtxBEaTXdFXvN
afhuNKsLBH2hJV5lToHaa02SJQKrgJDsAU6iT/7igIwoRODbViPLcCZF4lm3DIdc
pW39V3DGLyy2LJ4qEMW7
=cQyg
-----END PGP SIGNATURE-----

--=-ceULwQ+2DH4Pop0Rpv+F--
