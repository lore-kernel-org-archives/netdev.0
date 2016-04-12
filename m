From: Leon Romanovsky <leon-2ukJVAZIZ/Y@public.gmane.org>
Subject: Re: [PATCH for-next 2/2] net/mlx5: Update mlx5_ifc hardware features
Date: Tue, 12 Apr 2016 09:01:17 +0300
Message-ID: <20160412060117.GA24649@leon.nu>
References: <1460405422-8654-1-git-send-email-saeedm@mellanox.com>
 <1460405422-8654-3-git-send-email-saeedm@mellanox.com>
 <CAJ3xEMghu7ZB0YM8j_YJihpuNnDzOY2LU9-cTHwoWiBeYY7VPA@mail.gmail.com>
 <CALzJLG-PxUz9ov+cv4uiNSGpuxy0s9KamTvamV_g72SctqdhFA@mail.gmail.com>
 <CAJ3xEMhorMRsxtawjim9zoBn-zzoDXcMAJfHUqCZBNUbOKrMJA@mail.gmail.com>
 <20160412051537.GD25242@leon.nu>
 <CAJ3xEMijYrLvSmbNZp0B6AXqKGozz1rdZ58SCUP_09zOB6-2gQ@mail.gmail.com>
Reply-To: leon-2ukJVAZIZ/Y@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5mCyUwZo2JvN/JJP"
Cc: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAJ3xEMijYrLvSmbNZp0B6AXqKGozz1rdZ58SCUP_09zOB6-2gQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 12, 2016 at 08:36:21AM +0300, Or Gerlitz wrote:
> Conflicts happens @ all times, life.
>=20

=2E..

>=20
> I understand your desire to get it down to zero, but it's not gonna
> work, pick another target.

Maybe you are right and the time will show, but now we (Saeed, Matan and me)
are trying hard to achieve this goal.

>=20
> For example, the networking community has a fairly large rc activity
> (I would say 10-20x
> vs rdma), so when Dave does his "merge-rebases" for net-next over net
> and linus tree
> (4-5 times in a release), he has to this way or another solve
> conflicts, yes! ditto for
> Linus during merge windows and to some extent in rc times too.

I don't see any harm in our desire to decrease work overhead from these
busy people.

>=20
> > It won't help to anyone to split this commit to more than one patch.
>=20
> The commit change-log should make it clear what this is about, and it doe=
sn't.
> If you believe in something, state that clear, be precise.

I agree.

>=20
> As Saeed admitted the shared code in the commit spans maybe 2% of it.
>=20
> The 1st commit deals with a field which is not used in the driver,
> this is a cleanup
> that you can do in rc (net) patch (remove the field all together) and
> overall, w.o seeing

I don't agree with your point that cleanup should go to RC.

> the down-stream patches that depend on the newly introduced fields,
> how do you know there aren't such (unused) bits in the 2nd commit?

No, I don't know in advance, but the truth is that it doesn't bother
anyone, because we are exposing our internal HW to kernel clients and
doing it with minimal impact on the maintainers.

--5mCyUwZo2JvN/JJP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXDI8tAAoJEORje4g2clinbbgQAMmLxsisB5JhnwzfgkLj2E3G
fgcmP1Ko+viSnS34T5CeyFRT0PDNTX/XvaGpCH8bAj/Xkczadd9GfYBmSswKjOTz
EB92IK3kDZwWPpbzrEPtdgGG/lelVUyXQteW49fVcpCMnSiqPmsxEDXMeLz3RVWR
NUON5ipct08KnjaLJFB5JzOJ10hW+hopIOSAXx9o5IhHvYY/k6tR8qkJgty29mf5
PjMvpA7oi1w3PntMUKDHW5P9lRUaYmnyBgaK7jd6nBbFJem0s0DnBHjijsTJ+KJ8
mD3t0HPN+GgPIy8ePkyLVqGRqH5rk7hPet7+2bIfYYskKrErsyIVxlwUncTdsWIB
xM5eMvJDMXVgnLFsr4te/6w1k1EbAkQrYkj9qCU9G9afwZX6uxCqMWBbU1aogJei
6AcGpqQOsj3GckcqQt8dOkekj2RmQsGqyROQf0laWf7wSkzbYuNAXbsSxxrxSFVZ
ANqoSvmxbyP8CStL6zzW7IFdLGwOmYV6NdSI4YjOSGNR1JzSdEb615g4qDrselfe
Z67fuEsNJkxNnWqgnKFnKLZJtKGTUu1EyESiJtux+mH0hUzxxrUsyp/suOx76tPI
8Nu75rUeNTLo4Np079BhkrROGFgs5rpXuiDpSPV53itQC9XleGs4RUDiMGdIQ7IG
OijtSnobgxDe7qO7nl83
=qaHy
-----END PGP SIGNATURE-----

--5mCyUwZo2JvN/JJP--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
