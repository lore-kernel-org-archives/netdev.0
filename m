From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v5 00/16] Add Paravirtual RDMA Driver
Date: Sun, 25 Sep 2016 10:03:52 +0300
Message-ID: <20160925070352.GU4088@leon.nu>
References: <cover.1474759181.git.aditr@vmware.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="ZsW/usBbx2ObC9TW"
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        pv-drivers@vmware.com, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, jhansen@vmware.com, asarwade@vmware.com,
        georgezhang@vmware.com, bryantan@vmware.com
To: Adit Ranadive <aditr@vmware.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1474759181.git.aditr@vmware.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ZsW/usBbx2ObC9TW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Sep 24, 2016 at 04:21:24PM -0700, Adit Ranadive wrote:

<...>

>  include/uapi/rdma/pvrdma-abi.h                 |   99 ++
>  include/uapi/rdma/pvrdma-uapi.h                |  255 +++++

As Jason said, you need a very good reason to split and create number of
files per-driver in UAPI folder.

Please see my comments in respective patch.

Thanks

--ZsW/usBbx2ObC9TW
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX53bYAAoJEORje4g2clinokcP/AxGEF90Bk1Ae6nCF0y0qsuN
0UneRegGFHoamWblChCX8XVp23sP+dT3fmN/V1w2XM6wwRET3r79CjVafvQcRe9P
JOAtLnTY5wn2BWpPZ2JMFh6uCtoZzkur1L1npMQwMp2kOdmeN8ZyLOp7FdZ1wIsn
daaUN8B1POH2XfsDHtXR5yP/jeCO8R3y89hW7NU+/UioyAKHVuJNhJfvaw5rxDD+
s6pbQzEwXx8HYppmXqsZRkXCAwvAIn72piUS77aoMELxcpGuYKEHZHCOkfIxrEf4
Laox6f3u2OsBGKAajXaDLvE1A0uuezuRcyJ2LfP5wMH6TsdFUd0f9BRxJZtJmTdx
5kS/wQaOpw25q+e4I+vl/pn43/ZBEiiwrHsQH1n27936SVI8+4/AaZKvofmj2RqZ
vZnlytzl5g6+MqFAU4uNtYRCML18dILMLwoq2/g3vfF3JSW+pFwgRSbCCifvRJkX
nx8yq6l5jEdX7ndo19UPgubddCYzBferZvXk+q0kkarZG/TAB3G8nRqcAi1xpS/G
fmL3OiTjZNpUdQeWjwHmU8PNw2Ve0cxs91AIftXY97PJUnI9S26CVNXIQFCdwh05
NBNQXME4tW9NVADxmjPQuKBLbazQOECIdZeDxz3skW6kPrHg3GNAhucTI2fOLLZ8
nosimrkMs7Z3ojtG7y3H
=1C0J
-----END PGP SIGNATURE-----

--ZsW/usBbx2ObC9TW--
