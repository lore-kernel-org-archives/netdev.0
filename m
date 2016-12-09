From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH V2  00/22] Broadcom RoCE Driver (bnxt_re)
Date: Fri, 9 Dec 2016 18:27:15 +0200
Message-ID: <20161209162715.GA2521@mtr-leonro.local>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="ew6BAiZeqk4r7MaW"
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org
To: Selvin Xavier <selvin.xavier@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:59496 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934306AbcLIQ1U (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Dec 2016 11:27:20 -0500
Content-Disposition: inline
In-Reply-To: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Dec 08, 2016 at 10:47:54PM -0800, Selvin Xavier wrote:
>=20

=2E..

>  create mode 100644 include/uapi/rdma/bnxt_re_uverbs_abi.h

Please use already established naming format for this file.
It will simplify our future integration with rdma-core library.

Thanks

=E2=9E=9C  linux-rdma git:(master) ls -l include/uapi/rdma/*-abi.h=20
-rw-r--r-- 1 leonro leonro 2291 Dec  7 13:07 include/uapi/rdma/cxgb3-abi.h
-rw-r--r-- 1 leonro leonro 2488 Dec  7 13:07 include/uapi/rdma/cxgb4-abi.h
-rw-r--r-- 1 leonro leonro 2864 Dec  7 13:07 include/uapi/rdma/mlx4-abi.h
-rw-r--r-- 1 leonro leonro 6103 Dec  8 12:52 include/uapi/rdma/mlx5-abi.h
-rw-r--r-- 1 leonro leonro 2932 Dec  7 13:07 include/uapi/rdma/mthca-abi.h
-rw-r--r-- 1 leonro leonro 3380 Dec  7 13:07 include/uapi/rdma/nes-abi.h
-rw-r--r-- 1 leonro leonro 3918 Dec  7 13:07 include/uapi/rdma/ocrdma-abi.h
-rw-r--r-- 1 leonro leonro 2559 Dec  7 13:07 include/uapi/rdma/qedr-abi.h

>=20
> --=20
> 2.5.5
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--ew6BAiZeqk4r7MaW
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlhK2zcACgkQ5GN7iDZy
WKfUQBAAn8lggI2VCszVMjbMuqofZyteQNpeg8Cq7iUqmIk7QVNwqBwzCCaYYdcO
2ZOISRyV2l8aB9oCKZoJbWbjuHVpoZplHKijQc48OhNb0bFtpi3k7sk88lIHkeVG
LzdL+jPnCe57BLMR2EbQyS7OR+LOOAC0roHnaLLUYXS0kpHDrDbCXCLem2brEFee
SEom9MN/EHypp9WPFr9XzQrpf84Bdax41sbqklOuVlxmSpCHaBiyLlblEeOTwEKD
wpiUi3Y6fJJ+gEZLmM8Vz1zBBwTM2HsaXEx//mKMY3grYcJWzVQJhsjqERKpbsXC
TwNmgZN4PYc7y60PEt5rsofRxbge9fN/oAL+sbeZiaBGEMm66frfbx6GnB0hvq1V
aT4nk8/Dt2YABl4fqdp78fCn2QNVDYCFxaWz3Mgte+I4zQyXPatsR9rGuz+hkqW3
dWv6wsONsqwQaNdAlDzECqdU17vXtkv38tWHP+j0AZXesz8QlPtlt1E9ztcSsC1m
TU7bJXvJJjZnTnyJ9DiYQLY9WbUgQ2tKXf2rjRcH9VUusUMbJAgqLoSn3pdepaI+
RxOvwNA023RJczClk2xuYT6YcAibwSY/KrMszZS0zZkIXZQLfT4X5R/JWzf3Hk3w
aYp7mucVdzy64ZSKWX7pzzB4XNuT/A7Qv2u+6z3SFFg20jYApe0=
=nSN5
-----END PGP SIGNATURE-----

--ew6BAiZeqk4r7MaW--
