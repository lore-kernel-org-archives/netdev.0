From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC v3 00/11] HFI Virtual Network Interface Controller (VNIC)
Date: Tue, 7 Feb 2017 22:36:49 +0200
Message-ID: <20170207203649.GW6005@mtr-leonro.local>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="SCk9FC6hAD6beNza"
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--SCk9FC6hAD6beNza
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Feb 07, 2017 at 12:22:59PM -0800, Vishwanathapura, Niranjana wrote:
> ChangeLog:
> =========
> v2 => v3:
> a) Introduce and adopt generic RDMA netdev interface including,
>      - having bottom hfi1 driver directly interfacing with netstack.
>      - optimizing interface between hfi_vnic and hfi1 driver.
> b) Remove bitfield usage.
> c) Move hfi_vnic driver to drivers/infiniband/ulp folder.

I didn't read patches yet, and prefer to ask it in advance. Does this new ULP work with all
drivers/infiniband/hw/* devices as it is expected from ULP?

Thanks

--SCk9FC6hAD6beNza
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAliaL+AACgkQ5GN7iDZy
WKcaQRAAlVfTf6EPflFKnBY7ZrTqs7XYIvlx7Js3iALiH2bB+49t7X3oQPwUFaM9
VjRvi+Vpk02pDarnf17W6ElwGgWE2RYJg9cVl3HSjbF7iAAuA0fMwmTeiIQ2qyka
sR6Dex55VxVcM4vJBH11KTRrZTuKRhTpXvNlOlRz7xgbDT8l0kBTK7bYsPktIETx
+UG/QroJltouLit+saRXxO35K6pvx8pHmThKzTlORIO7iIqr9gBpD5XnZHKnscDq
rx8gGIKzBrNrgvGipLI61EJJ25BnFB8s1K7TFCBSaPSzIY+4/jE/SfU4bOsaKa2d
Q7PpTc6JYQBG7r7ywZEHZnc9/YQRc9QztvpCfC+ya8zqJntYoTMXjxZM3If8Al2C
JCFVoSWOAa2+gF96oZ1H82HyNhhKnGoMhiTTUpgN2A0yRQOVUcIiFZSVhs8T3+vk
Vymy88BeVnT7ge+Mqh3PnwPbjSJupBSZVexxr6oNXct3BxUb0vT0umkOjA0MaODd
39DPHw3OM/jSH1eUtzl60simaMMMtOIv60iUAFWrU18snsK8zQu46XVz/WaWi3mk
scFjQCCd/366stG9XjsUjsNrBs/mDcOHG5gwx08r9xZmpZ6pUwDFBmh3XRI9Jaq6
39twCBDxSAHTsEm+90vziv9UZ+6PawJqaNS9pKMLqH0EM0Ii3fY=
=uLY5
-----END PGP SIGNATURE-----

--SCk9FC6hAD6beNza--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
