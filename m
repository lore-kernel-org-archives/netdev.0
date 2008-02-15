From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] add macro for printing mac addresses
Date: Fri, 15 Feb 2008 13:54:40 +0100
Message-ID: <1203080080.8931.190.camel@johannes.berg>
References: <20080215104804.9870.15722.stgit@one>
	 (sfid-20080215_104829_866984_5F977706)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-EXfC4rmfM1w7DszFHSLv"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: Bruno Randolf <bruno-L9ZBdB2wSWtl57MIdRCFDg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080215104804.9870.15722.stgit@one> (sfid-20080215_104829_866984_5F977706)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-EXfC4rmfM1w7DszFHSLv
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Fri, 2008-02-15 at 19:48 +0900, Bruno Randolf wrote:
> is there any chance to include a macro like this for printing mac address=
es?
>=20
> its advantage is that it can be used without the need to declare buffers =
for
> print_mac(), for example:
>=20
> printk("mac address: " MAC_FMT, MAC_ADDR(addr));

you want print_mac()

johannes

--=-EXfC4rmfM1w7DszFHSLv
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR7WLj6Vg1VMiehFYAQJmgw/+LKWzUJsNuRB4FtjE2SeHsaiK/tpDjrW3
oE9FRz7fW8LkLFlQ2eLHVrFiZgBL07kU32O2I7IHCLa2LRGtEPAjkLsbX+bLayiu
6TOkF1dA6XunaOGh4kRG8hm4EiAwGbfAOFPXT4XMSBI0VsTy543k0iYhHo7Lke9k
CxxyKcc5rURz+R62rFfN/OH52+rSXgmwP3fh7T///ctteqRaGlNJtQD1/CznF6IO
SD+0VbQFj4muLZwcggkzMtr82w+CqqMNwwQUcamJ0twFqmhR9Eg2SRdhS8oD2NmY
gWaBxpNc5yxQRy7D7Tx7viR3CZYmXBcY6Es8HA89VswiwyubXbqsP7TtNDZ5DYhu
7xpM0Pwrwd4LCwCTINdnMzNWdt//3WPNucjyh2cpnq9zmGT9rnTVPO4wOINBVfXG
T2Ctzr7eMn3kfrSrqWAGREDo5LFYqWOr/GJUZm8/KxvQtK+r7+RtugctNVb5TyhH
NaEnLNINKRY5IXrZSvnFp0EozFOWSg6gtzml1O0pfc8Sqld/iLN6xdY6ufB4bVp7
244Be7z0u/K1IFjbNMhTOP0OEt0YatclSxfOw4f6jCuXvbhuCpDL4msNkRTqZhMR
5z2cv1FYXb+hbw9F1qYIqnHStd1GZSZJTQy5RKmSQnaGYZuMUE+b6zHpaT9ohR9N
rLvaUBVl9iw=
=/pg1
-----END PGP SIGNATURE-----

--=-EXfC4rmfM1w7DszFHSLv--
