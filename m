From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V1 00/16] add Intel(R) X722 iWARP driver
Date: Tue, 22 Dec 2015 14:09:29 -0500
Message-ID: <56799FE9.1050305@redhat.com>
References: <1450739596-23276-1-git-send-email-faisal.latif@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="GlkQiNUs595xBF2JAel47GP2H03Ale49g"
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1450739596-23276-1-git-send-email-faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--GlkQiNUs595xBF2JAel47GP2H03Ale49g
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 12/21/2015 06:13 PM, Faisal Latif wrote:
> This (V1) series contains the addition of the i40iw.ko driver after
> incorporating the feedback from Christoph Hellwig and Joe Perches for
> initial series.
>=20
> This driver provides iWARP RDMA functionality for the Intel(R) X722 Eth=
ernet
> controller for PCI Physical Functions. It also has support for Virtual
> Function driver (i40iwvf.ko), which that will be part of separate patch=

> series.
>=20
> It cooperates with the Intel(R) X722 base driver (i40e.ko) to allocate
> resources and program the controller.
>=20
> This series include 1 patch to i40e.ko to provide interface support to
> i40iw.ko. The interface provides a driver registration mechanism, resou=
rce
> allocations, and device reset coordination mechanisms.
>=20
> This patch series is based on Doug Ledford's k.o/for-4.5.

Please use shallow threading on patch submissions like this.


--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD



--GlkQiNUs595xBF2JAel47GP2H03Ale49g
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJWeZ/pAAoJELgmozMOVy/dwxEP/3/k35ECWSEZMMzRvVHBtRQK
Z9sJ8svC44HmJKK5atfdE3wTk5kbCTKQdOYzShUJy87o7dfyUWrnLyxr3WcC65/y
hSh+w9sAnSKiuRZylwWEUXdnZRRP8HgsbMU4cQt9JVZZO6srSeR99ZsgwfFqwJZM
8GM0yuqB8UcGQPyAuj5poD07x+J7H6nRiyRHYpHo0P2nPQvIFHqXeyyXI0uoZ9wH
vD5ys1oIwtvHAu+MBSWARbvyen9b87Z9mqiLmN8pHgdKU1OQhcL7+p9B+hX6BM5L
3mQx8MVVEtFpBqoy9XalgoxZNnHui0ByhIdtzfCKmyZ/DPyttAjGRgxWi0A7lGPE
9RDOZBcwgeijR6TDLvVCuA48a/B6Ykw0knc3i4nZPcUdYQsqEsStrcl1r+PHRvNj
nljNG7dkoYZd49PardSxUu5ERrEaRZ4Gh+oY7tQoHiRXOJ3iVTuD8sXlKwWZP8Se
TriDrsavPXuI70lmI4/9jISGMt8vWF6gostFerN7AeKf+13ZRV5BPXIMIDpzKg+p
ggr7wjEuay0iEoCUpMLl9G+VCxrYMsuxQsI89+BmLAcHIwlr5AA7xjnDvv1adN1q
kGokipUV4ZPEq1gc7G6QGZBgYb6ilX1nineeSfI5eHdFD2Y+1ZkNA4HQttBt8NMs
6N+hNahLd26h9EMeXQ5X
=o0s8
-----END PGP SIGNATURE-----

--GlkQiNUs595xBF2JAel47GP2H03Ale49g--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
