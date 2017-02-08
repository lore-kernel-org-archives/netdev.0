From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [RFC v3 00/11] HFI Virtual Network Interface Controller (VNIC)
Date: Wed, 8 Feb 2017 07:30:11 +0200
Message-ID: <20170208053011.GY6005@mtr-leonro.local>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <20170207203649.GW6005@mtr-leonro.local>
 <1828884A29C6694DAF28B7E6B8A82373AB0E5B0B@ORSMSX109.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="7jzg8fevGm/yfsZp"
Cc: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Dalessandro, Dennis" <dennis.dalessandro@intel.com>,
        "Weiny, Ira" <ira.weiny@intel.com>
To: "Hefty, Sean" <sean.hefty@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:37016 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932071AbdBHFaL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 00:30:11 -0500
Content-Disposition: inline
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373AB0E5B0B@ORSMSX109.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--7jzg8fevGm/yfsZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Feb 07, 2017 at 09:00:05PM +0000, Hefty, Sean wrote:
> > I didn't read patches yet, and prefer to ask it in advance. Does this
> > new ULP work with all
> > drivers/infiniband/hw/* devices as it is expected from ULP?
>
> Like the way ipoib or srp work with all hw devices?  What is the real point of this question?

Sorry, but I don't understand your response. Both IPoIB and SRP were standardized
and implemented years before hfi was brought into the RDMA stack, so on
time of introduction they clearly supported all the devices.

Does this VNIC interface have standard? Where can I see HFI wire
protocol to implement HFI VNIC support in our HW?

Thanks.

--7jzg8fevGm/yfsZp
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAliarOIACgkQ5GN7iDZy
WKdpZQ/9Hkzj3UxmKiOh34L8VKAb5KAgt7zYvLiZVWlUKPYhGk+C+eYjC2IbuJvR
6TkSB5DI2FyRREnXVOG4iSqJjarTMOUxysNvldcfGn32ofIvCS1VECqgb8ALoDEb
hSUURyb9KhghFdVviSJFT5RYMaKoy9HMXbLe1/zEupp4wMefW+Z9GfJhJSak1wjm
KT/eOLEf4TrjdOqQvz+VFBUhz7/V4nJr+R2WYxu9D2QoNkqLJMHJK4TCSLYMh2rO
cu6vUdiKzeWEm9bcTcA2BlS2d30aVAqbJu+pG83b52HCYXNtUsb9T9oxfWo65hrq
UbWQR+JSrAlVR/OERptPwZaomaI4wJl+pLe4++/n+2RYCd0Cw6fxBlMLMbM0AVEG
tl7biavDohR68pTkPo6VM6EdxBSMnpcPkKekXItPn1paeAne6QlWkumNQ5T1Pl5F
Ors8/kx+IbFy4v1DfI5fEktFE3wsXXlMYVCu1RBfLgMWGU+DgR2uRbyk1lEFam29
jufFBtY7yFc3OmuYJAE35ueuunWGEwPwNn9RlUHe/7FYoqCV/OJ1TT3iE+kK8zio
LKDlMYClHb2hTjxPAGXr1ujMxlF7phjB+aLwb1HjbmPzH2PoMTMc90rCuIKFJotA
LwxILY3kF4G2g9UPshcOAN481I4UqNV0bO4JPq/ck5fPTvMPA08=
=VDC5
-----END PGP SIGNATURE-----

--7jzg8fevGm/yfsZp--
