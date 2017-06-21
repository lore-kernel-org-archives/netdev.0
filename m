From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH rdma-next 17/19] RDMA/netlink: Add nldev port dumpit
 implementation
Date: Wed, 21 Jun 2017 18:21:23 +0300
Message-ID: <20170621152123.GI1248@mtr-leonro.local>
References: <20170621060528.3752-1-leon@kernel.org>
 <20170621060528.3752-18-leon@kernel.org>
 <023a01d2ea9a$9d1fb610$d75f2230$@opengridcomputing.com>
 <20170621144211.GE1248@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="WR+jf/RUebEcofwt"
Cc: 'Doug Ledford' <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        'Chien Tin Tung' <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        'Stephen Hemminger' <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        'Jiri Pirko' <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        'Ariel Almog' <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        'Linux Netdev' <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170621144211.GE1248-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--WR+jf/RUebEcofwt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jun 21, 2017 at 05:42:11PM +0300, Leon Romanovsky wrote:
> On Wed, Jun 21, 2017 at 09:28:12AM -0500, Steve Wise wrote:
> > > From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > >
> > > This patch implements the query interface to get all
> > > ports data for the specific device.
> > >
> > > Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> >
> > The fill_port/dev_info is just filling in names and indexes.  Shouldn't it have
> > all kinds of goodies about the port/dev?  Will this be enhanced going forward as
> > needed?
>
> Yes, exactly.

You can see, it is happening in patch #19.

Thanks

>
> >
> > Reviewed-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
>
> Thank you a lot for your review.
>
> >
> >



--WR+jf/RUebEcofwt
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllKjvMACgkQ5GN7iDZy
WKdQvQ//adj87IEnMDUZIU0zn+Rj6Ihv1H9PfcSZQ2EcbByUDncDUBzVdqYsp+UW
7DDZXWoMx4vdVdIJhTKR3IpQ8vle4B5iuy//BRz+3hCgTl3FAubmowI7igr+piaT
Yj6EgOE3nijGbiWEO3qEKOz+xz/1wtXaiEG2YTU4oR1Rvc1pe8oZM2DpEZ+ZmqsM
URszLd5syiiaRUn+It8kS8+vZqebtnBDDVwCaQaqZ+icIZqWmLOUATROZlNTqNkm
Oe/QAlRr+9Ju3gMGZeM7kqeAlCs1HRNfvvE18tZA8bbLi0RY/jzkKXlJjii4JOaH
aMgiWH/IYtxdhccyG9+NRs3IMJd5dkJdRB8FpMBgDe2hfE2hwwdr3AjsnhZohPsl
jYrpxaaM5s1QeUyk6hOQqPQshwmUNIyECDnFjaZWDKSAuKHnD5HRpSu0yQLfjCP1
r6sUPxT6d6ywO9uSU4v+qowbcZL+cN8p2XNX8DaMwQuUrCS1j4iLK84I5B5JUA5E
0kB0RiGjNNKpF5c2V+QGhBAkujBPOpeMVdKc7FgAzOnroJM3FNhYz5OEd32IPZJc
Uf5+oXaMiKHcdxcllwLSswhhh739ep57/KwCSIcxtoEa/2bhCJVDn4ufHXtoJxQc
qLw7wFaGUkjHuZG1bwh9/f4pjS4mP87IHw1IxW44Vy+u4xREv7Q=
=urkz
-----END PGP SIGNATURE-----

--WR+jf/RUebEcofwt--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
