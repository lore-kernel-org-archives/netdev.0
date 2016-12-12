From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH for-next 0/6] IB/hns: Bug Fixes for HNS RoCE Driver
Date: Mon, 12 Dec 2016 17:09:47 -0500
Message-ID: <f3d27be6-1a4b-8218-2449-35c9ac0c0e3c@redhat.com>
References: <20161129231030.1105600-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="IS80GlpGFL96gCgSelFB9aPI8ahLMvekX"
Cc: xavier.huwei@huawei.com, oulijun@huawei.com, xushaobo2@huawei.com,
        mehta.salil.lnk@gmail.com, lijun_nudt@163.com,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161129231030.1105600-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--IS80GlpGFL96gCgSelFB9aPI8ahLMvekX
Content-Type: multipart/mixed; boundary="6SeOr5TW2vfmP5jORpO73qB0k0m0S4Ij7";
 protected-headers="v1"
From: Doug Ledford <dledford@redhat.com>
To: Salil Mehta <salil.mehta@huawei.com>
Cc: xavier.huwei@huawei.com, oulijun@huawei.com, xushaobo2@huawei.com,
 mehta.salil.lnk@gmail.com, lijun_nudt@163.com, linux-rdma@vger.kernel.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linuxarm@huawei.com
Message-ID: <f3d27be6-1a4b-8218-2449-35c9ac0c0e3c@redhat.com>
Subject: Re: [PATCH for-next 0/6] IB/hns: Bug Fixes for HNS RoCE Driver
References: <20161129231030.1105600-1-salil.mehta@huawei.com>
In-Reply-To: <20161129231030.1105600-1-salil.mehta@huawei.com>

--6SeOr5TW2vfmP5jORpO73qB0k0m0S4Ij7
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 11/29/2016 6:10 PM, Salil Mehta wrote:
> This patch-set contains bug fixes for the HNS RoCE driver.
>=20
> Lijun Ou (1):
>   IB/hns: Fix the IB device name
>=20
> Shaobo Xu (2):
>   IB/hns: Fix the bug when free mr
>   IB/hns: Fix the bug when free cq
>=20
> Wei Hu (Xavier) (3):
>   IB/hns: Fix the bug when destroy qp
>   IB/hns: Fix the bug of setting port mtu
>   IB/hns: Delete the redundant memset operation
>=20
>  drivers/infiniband/hw/hns/hns_roce_cmd.h    |    5 -
>  drivers/infiniband/hw/hns/hns_roce_common.h |   42 ++
>  drivers/infiniband/hw/hns/hns_roce_cq.c     |   27 +-
>  drivers/infiniband/hw/hns/hns_roce_device.h |   18 +
>  drivers/infiniband/hw/hns/hns_roce_hw_v1.c  |  967 +++++++++++++++++++=
+++++---
>  drivers/infiniband/hw/hns/hns_roce_hw_v1.h  |   57 ++
>  drivers/infiniband/hw/hns/hns_roce_main.c   |   26 +-
>  drivers/infiniband/hw/hns/hns_roce_mr.c     |   21 +-
>  8 files changed, 1026 insertions(+), 137 deletions(-)
>=20

Series applied, thanks.

--=20
Doug Ledford <dledford@redhat.com>
    GPG Key ID: 0E572FDD


--6SeOr5TW2vfmP5jORpO73qB0k0m0S4Ij7--

--IS80GlpGFL96gCgSelFB9aPI8ahLMvekX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJYTyArAAoJELgmozMOVy/dekQP/1KO5zXXaDMi/X72qhc4rqok
/awQXP5VpG0J6asTFMVblHYpzN+Mgqy+dEnf8Qg26TH8UYOAy3Lfmay2OCK79i/L
gQZOPbiFed8mHBtGw0NoP608KlsZWbbRq87UBcNXsIw5iGwOgd0MTLhyJtMHxJ6p
4GhEbTdWXBiOEblyOQfvXnSa7w8Vn3gPCTGSzIxiloalTn58lpvrs1sePNgsU8+1
XrMk/SLbUPRvjFaT3nAor1rUeGXO9Bvw9XQK1FVGyavZSlhJFlKMsJlzpq1gaJC+
c0d6y98VOdcEVmFXagE9NpmAmlQOOPCjf/DxSYXb3TgyTX8ylhFOtoSOlivxgNld
uGuVBO3HnbgULSD4LPUIWy7dumatgA/1pQYRpNeljBjy4ShG6SfT3nbEyCsrr+7q
jnHhE8Uu6IeDBBuQT9F1LjAUj8vHE9+YCZfJ6hHey1RLjZrXcx9P5WHbFcmKk2ld
S5E6XW3Pu89tCzSNqoVbZtx0ytiOnz8wZbA5pacIGjFN4Segq1e0Uy6mMJrBqhph
xu4c2GM2RzhLps0xHHk7/U8F97fzWeKHLV11iePBxvqHltWm3l+mBbpyn00zIvN2
EtyJJKhVrxtkWRr4kzzSFwVSLFob54Dtd5pkHSE0YmUQnFJFdgo1PQC3DveM/ZKX
PxJ4takObOj6K175C1gV
=kJc1
-----END PGP SIGNATURE-----

--IS80GlpGFL96gCgSelFB9aPI8ahLMvekX--
