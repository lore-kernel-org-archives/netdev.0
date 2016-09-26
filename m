From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v5 00/16] Add Paravirtual RDMA Driver
Date: Mon, 26 Sep 2016 08:57:24 +0300
Message-ID: <20160926055724.GF4088@leon.nu>
References: <cover.1474759181.git.aditr@vmware.com>
 <20160925070352.GU4088@leon.nu>
 <9f65ab5c-d8c2-e8e3-9334-5d1865a20dc9@vmware.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="nCRcqX7cEx7rr7Pe"
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        pv-drivers@vmware.com, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, jhansen@vmware.com, asarwade@vmware.com,
        georgezhang@vmware.com, bryantan@vmware.com
To: Adit Ranadive <aditr@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:49604 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759799AbcIZF5b (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Sep 2016 01:57:31 -0400
Content-Disposition: inline
In-Reply-To: <9f65ab5c-d8c2-e8e3-9334-5d1865a20dc9@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nCRcqX7cEx7rr7Pe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Sep 25, 2016 at 10:25:12PM -0700, Adit Ranadive wrote:
> On Sun, Sep 25 2016 at 10:03:52AM +0300, Leon Romanovsky wrote:
> > On Sat, Sep 24, 2016 at 04:21:24PM -0700, Adit Ranadive wrote:
> >
> > <...>
> >
> > >  include/uapi/rdma/pvrdma-abi.h                 |   99 ++
> > >  include/uapi/rdma/pvrdma-uapi.h                |  255 +++++
> >
> > As Jason said, you need a very good reason to split and create number of
> > files per-driver in UAPI folder.
>
> I can move the pvrdma-uapi.h back to the pvrdma driver folder.

Yes, please.

--nCRcqX7cEx7rr7Pe
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX6LjEAAoJEORje4g2clindLIP/jgUoUZPBbrikjk+BK1cdCH7
JFgcG/+qH4csI4PKYA+Iwzf1fq/p6GruYXtaNfH/w5i2C/CCFIwclfTKOJvfdlfT
1URXp1V4ip3K0UxRtzxU+YWzGowZ/SXz1e+ERJBOfcBHW6mDS/ttEIuSaXhT1Q3J
5oKBvnjQEz1El7GHdU/8GTHw5nUZWHnmxFaOYPoNeyvrjyijIt/2kZhhIQ9/7jbX
0P3rT9tNHWchFc/ySRzQfULeKRTsUPvsL1H8Cq4NlYTYHGIiHCMpBkv+gs+OrbSK
D2CgLYcJhtXKk5zYCSHvEARPTXbZ/tP935CBGIERMAscPlIxI9clMu2SqTloy/E4
V7CSV1yD5VQCkNKCYv5v+TKQmwbNvP6zEV6cNwSVnhIQjSPWqtF7Bv4ju3neapcf
BqoCenjNDu3E9d8EIzZoI2CsVAnV+jwnA1J3+vjxbUU7CGRjovGT+U74KLO60PA6
d8Cde/6OJ2ItbG0rEByNlUjAweVrQa1o3t3JBu5KgWxUcCyvqqZWytYPXX/9zjO+
IDjtkdYmcveXfHss/e0ELa8cNWrTa7fzgcuQ5Hnc8SUVbNcoIgilyFdmBSRpNZvA
pPWMUSYG1aXAlN80lAo6Ni1BarLieCD6LDeicavdiONYfxB7tQcaImlxjcCHhRpx
A/Zj1v4nLt18MNBDUZOZ
=gVJf
-----END PGP SIGNATURE-----

--nCRcqX7cEx7rr7Pe--
