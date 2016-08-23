From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [for-next V3 00/15][PULL request] Mellanox mlx5 core driver
 updates 2016-08-20
Date: Tue, 23 Aug 2016 15:01:00 -0400
Message-ID: <1800343a-1aeb-82ad-b3fe-8633b55103bf@redhat.com>
References: <1471942157-9131-1-git-send-email-saeedm@mellanox.com>
 <1a97f16d-5a0a-cb06-6e5c-1b6f9fa7c609@redhat.com>
 <CALzJLG8=+D2a-dtaTMJWu_95Mdroh51Ph3dGths1eO3spzp58g@mail.gmail.com>
 <20160823183926.GL15065@leon.nu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="ro3iGM1buWDQ7PCdS4b9L4HsKsWmoMJAf"
Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160823183926.GL15065-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--ro3iGM1buWDQ7PCdS4b9L4HsKsWmoMJAf
Content-Type: multipart/mixed; boundary="DJO5GJAN8ow2N1ucrUbFdFj9fomeawEWr"
From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Message-ID: <1800343a-1aeb-82ad-b3fe-8633b55103bf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [for-next V3 00/15][PULL request] Mellanox mlx5 core driver
 updates 2016-08-20
References: <1471942157-9131-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
 <1a97f16d-5a0a-cb06-6e5c-1b6f9fa7c609-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
 <CALzJLG8=+D2a-dtaTMJWu_95Mdroh51Ph3dGths1eO3spzp58g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
 <20160823183926.GL15065-2ukJVAZIZ/Y@public.gmane.org>
In-Reply-To: <20160823183926.GL15065-2ukJVAZIZ/Y@public.gmane.org>

--DJO5GJAN8ow2N1ucrUbFdFj9fomeawEWr
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 8/23/2016 2:39 PM, Leon Romanovsky wrote:
> On Tue, Aug 23, 2016 at 07:10:53PM +0300, Saeed Mahameed wrote:
>> On Tue, Aug 23, 2016 at 6:57 PM, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wr=
ote:
>>> On 8/23/2016 4:49 AM, Saeed Mahameed wrote:

>>>> From Hadar and Ilya, added the needed hardware bits and infrastructu=
re for
>>>> minimum inline headers setting and encap/decap commands and capabili=
ties,
>>>> needed for E-Switch offloads.
>>>
>>> These looked fine to me, but aren't really in the RDMA area anyway.
>=20
> Our internal goal is to have 0-merge conflicts between RDMA and net
> trees.
>=20

Sure, I'm aware of that and fully understand it means that a single pull
like this will have mixed patches between the two.  I was just pointing
out that even though I looked at them and they looked OK to me based on
my cursory review, they are something DaveM needs to approve, not me.

--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG Key ID: 0E572FDD


--DJO5GJAN8ow2N1ucrUbFdFj9fomeawEWr--

--ro3iGM1buWDQ7PCdS4b9L4HsKsWmoMJAf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJXvJ1tAAoJELgmozMOVy/d8dgP/AzedB/Yg4vplS7rOYO7mXhk
NecFNUukJRaOlmOEE0nsqS3mB4UkHX/zSvS8xq2zIt/edqiuPyUDNuTqhbvYLJBt
SRL228cNxriJXVe3sHBmIBwypyIV2eZpsAYKiMapCLbua8ZmQR/TXiCantV85VrM
FYKFAZLiy+akE3BUVjiS/BjDsM4ZZE+NLhr/FkEmwxm7iHqV4bJ6WMycJs3gdmJs
LrKc5JDVQmv+gUP5IYnRZskjEj4MckrnhxhR35mOAO6Q0eo0npTUKdYWP846wzqn
Qsu4fKvJfs64KscIJ5WlJxUmwhdZP9aIzbC4w8uhM6w5EIOKJJYLwJEX2bM55I5U
GzrYdS7ANJ76VUcHGcTRoU9b6pGsZetaBSQMS8pn4g19BQR85rYl8xFNecImFvTy
RtSCmkWRnUpDBDxNRoXSZOnw+f5VYZDpGVch2vBDilTdaqLwNg4yVxVTNbVkh7pD
Ig55rmN9YbtLJCL33ArLooeXYdnT1LmOIQJhd2mbD3pH3qIAduyj4lEbs3FdTH0V
a9IXCDsDEhDa9BCsXQnx1OJ7HcZvG2yzUrFx3zTWi5JhTSiogIPzJToHe7ULyLnx
8SVB4wdLxpaW/+hthhr/OxLlLsS0Grkkb1fT9DlHBuvISLyOSmj0FvZYnhZTUb6e
x008uMhI2RCirUBC5pKD
=nD9S
-----END PGP SIGNATURE-----

--ro3iGM1buWDQ7PCdS4b9L4HsKsWmoMJAf--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
