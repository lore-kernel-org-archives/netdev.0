From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH for-next V2 00/11] Mellanox mlx5 core and ODP updates
 2017-01-01
Date: Tue, 24 Jan 2017 14:39:59 -0500
Message-ID: <1485286799.43764.49.camel@redhat.com>
References: <1483349868-11716-1-git-send-email-saeedm@mellanox.com>
         <20170102.155341.1496970446718890403.davem@davemloft.net>
         <CALzJLG9ZBRMOVqFsTypCLV6Rrek8a9g43z0spvVKeku6WdWCTA@mail.gmail.com>
         <20170103072344.GF12077@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-kv+qCPI1IaLuc2KUAjdX"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ilyal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        artemyko-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170103072344.GF12077-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-kv+qCPI1IaLuc2KUAjdX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-01-03 at 09:23 +0200, Leon Romanovsky wrote:
> On Tue, Jan 03, 2017 at 01:30:16AM +0200, Saeed Mahameed wrote:
> >=20
> > On Mon, Jan 2, 2017 at 10:53 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> > wrote:
> > >=20
> > > From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > > Date: Mon,=C2=A0=C2=A02 Jan 2017 11:37:37 +0200
> > >=20
> > > >=20
> > > > The following eleven patches mainly come from Artemy Kovalyov
> > > > who expanded mlx5 on-demand-paging (ODP) support. In addition
> > > > there are three cleanup patches which don't change any
> > > > functionality,
> > > > but are needed to align codebase prior accepting other patches.
> > >=20
> > > Series applied to net-next, thanks.
> >=20
> > Whoops,
> >=20
> > This series was meant as a pull request, you can blame it on me I
> > kinda messed up the V2 title.
> > Doug will have to pull same patches later, will this produce a
> > conflict on merge window ?
>=20
> Yes, but it can be easily avoided.
>=20
> Doug,
>=20
> We have another pull request to send and we will base its code on the
> Dave's tree instead of Linus's rc tag. In such way, you will have the
> same commits as Dave and won't have merge failures.
>=20
> Please don't apply manually this specific patchset.
>=20
> Sorry for the inconvenience.

Hi Leon and Saeed,

As I understand it, Dave took this series, but I have not. =C2=A0You were
going to base another pull request on top of this so I could get both.
=C2=A0However, I believe that was the attempt to reorg the driver pull
request, which David NAKed. =C2=A0That means I have not picked this up. =C2=
=A0Are
all of the other for-next patches you posted against the RDMA list
going to go in cleanly without this series, or should I expect
conflicts between Dave's tree and my own?

--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
=C2=A0 =C2=A0 GPG KeyID: B826A3330E572FDD
=C2=A0 =C2=A0
Key fingerprint =3D AE6B 1BDA 122B 23B4 265B =C2=A01274 B826 A333 0E57 2FDD

--=-kv+qCPI1IaLuc2KUAjdX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJYh62PAAoJELgmozMOVy/doZcP/jCu3J47eISfA0nt26GEE6wZ
HW33PpRB2hOg8h2IYy1XGmk810yzfaxEYJt/yKs9G0iB54IEvAKiBdmhhsxHNgfv
2EXUuVwt3XzjxPKWOHsH8VZpX7f28f/IZqZ/0LVpnldWAvSfZ1lqyJF+TFhsGON7
OS/wFYK3IFMARgbcBwtrKe1h7Z7GIk22RSsOaoTFvQEXXR+UEWXHAflFqfVz2kDg
s5qLuQcbsDCy0QeUvPu6m1ukOZ0gtozHZ9jp57bFr8lGQ+/RzfpiQiNoXThz4/BI
sXnrRpL25k+Ek0ySW96hs+CmcUru5w/HZ0tmSJ+4IQMZ+M2ectS1RTtuvq91Qvdb
E5UMgJetxNjn5kVhSJ9688vmIM2lAySGJwrmqCFyZiVmLryx1PZFAaSGIQoCfOKS
2WEMS19yK2nCzV+VB2P9NMiebLnQtWoBvkOZiax0gBPM+YN0J7Om0QoQM4bhd6AZ
OZQL8JN2yfr9Ceu+j99hKm2/2qrYPnCVh7P4TpaRWePPKvJLc8COlnzAiYCiuWii
ua6cNzWaig0GJHHdV8cSnYfO1jMh4ZeEY9FWs42hv+Aab/2Xd8dgHThibOcookgm
o6ME3HwegZuX7UkiV8pse3vhmamcbmIV39/DMvpXAP2ls6Grz4pgVOkDP3oE/D59
IJJRdslHr8ZSf/D8iste
=ryka
-----END PGP SIGNATURE-----

--=-kv+qCPI1IaLuc2KUAjdX--

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
