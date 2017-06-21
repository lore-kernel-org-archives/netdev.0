From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH rdma-next 17/19] RDMA/netlink: Add nldev port dumpit
 implementation
Date: Wed, 21 Jun 2017 17:42:11 +0300
Message-ID: <20170621144211.GE1248@mtr-leonro.local>
References: <20170621060528.3752-1-leon@kernel.org>
 <20170621060528.3752-18-leon@kernel.org>
 <023a01d2ea9a$9d1fb610$d75f2230$@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="maH1Gajj2nflutpK"
Cc: 'Doug Ledford' <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        'Chien Tin Tung' <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        'Stephen Hemminger' <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        'Jiri Pirko' <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        'Ariel Almog' <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        'Linux Netdev' <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <023a01d2ea9a$9d1fb610$d75f2230$@opengridcomputing.com>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--maH1Gajj2nflutpK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jun 21, 2017 at 09:28:12AM -0500, Steve Wise wrote:
> > From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> >
> > This patch implements the query interface to get all
> > ports data for the specific device.
> >
> > Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>
> The fill_port/dev_info is just filling in names and indexes.  Shouldn't it have
> all kinds of goodies about the port/dev?  Will this be enhanced going forward as
> needed?

Yes, exactly.

>
> Reviewed-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>

Thank you a lot for your review.

>
>

--maH1Gajj2nflutpK
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllKhcMACgkQ5GN7iDZy
WKfwug//TJYMvnZkC9hOnW/XZXezXWq7Kdf0uxMdL655lWa/VZQonaUcIhhHxRv6
aAYU2BLXID4OzS1qqYt5QdnUZdtXD+RytvwVq0fwxt7er1YI0bUiApHIrM2vubdD
NP9P8kb4GzkASTsyBVX3kPg/5DLtGWhcq//nV2zbfKvI8hJyLh45ov5Ghe52KeLt
T379QWd+vR5sRKc+WRf1c1Evdv0PKFiDgjPlooES8zbGcxsxopIXolj1WDWsX4jd
f3KSzyT8Z3tGOfFdUQt/W4uN4iEUxFtSXPPNx6xxCf9aVSQLoNp/GpdpBpt+YrsD
ljjCxuDWR5qZkFfCxLI7E5m9axEND+ChN7DuO1h863jaQH00gpVe/Wi0D60e0nYk
eonTr9wEhvC5S4euE8u+ZnmulxFq0tOh9A44Pe/q96cr4yCrgKMS7BFzaYGP6CMd
AboqHJQ9eUGWQqBWXSNNvWe7gaMGgFPz0LOX8iKZVpS0rhOpXhTYNl510QvEeMJM
yo+0tc2pJR2wbhO/eez+JGXU9/lPh8qc8Krzo4PGfEKpv/NXLsvWo3nWpcRw+37t
FE9pqVvMxLY7EhXkw7HH55aGkgXZmomxdAdkqvsYt2gISzHFfFImN0WpeimyPhX6
1J2VwusqpVLJfERckwhINZ/TVRFIUyXO0LKG/KKsA3FDA6wlICI=
=vSib
-----END PGP SIGNATURE-----

--maH1Gajj2nflutpK--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
