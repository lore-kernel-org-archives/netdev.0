From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2008-11-10
Date: Tue, 11 Nov 2008 00:52:28 +0100
Message-ID: <1226361148.3650.22.camel@johannes.berg>
References: <20081110204500.GL3546@tuxdriver.com>
	 <20081110.133054.154011074.davem@davemloft.net>
	 (sfid-20081110_223131_713357_23FD2C3D)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-+mUA9Y0UCwFMPFPVgwxg"
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081110.133054.154011074.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (sfid-20081110_223131_713357_23FD2C3D)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-+mUA9Y0UCwFMPFPVgwxg
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-11-10 at 13:30 -0800, David Miller wrote:

> BTW, I noticed that print_ssid() is a good candidate for a new
> %pX format specifier extension, just like how we got rid of
> print_mac(), NIPQUAD() and friends recently in the net-next
> tree.

I was thinking about that too, but unless we want to do something like
adding %pSSID I think we shouldn't do this for so few users.

johannes

--=-+mUA9Y0UCwFMPFPVgwxg
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJGMk5AAoJEKVg1VMiehFYuMsQAMH2sBL5k6u3xZJnR7Lu1lMA
WcEMgCAvU3u+Do43zp97pcjfxi5y26DZ/HWootKGPyjwD/bUu9vr4ChfA1u986pT
fKB2oUQj6Vcq6sdt/hPudA8kX6bOp11IkWGJQ5/L0peY17avX0MzcZq8FB9lmanU
7IP9jG6J1lr6idIIx7JYAMe8NuGuPyIUzCKC5uNv+NJtlDC10Cy6YHKIE6WXh+H7
Hyn5PvEobwiCjrLoxt8+OP8VFFy69AF1AQhLQVn5XxeI7coGd9460WRiqX3FTcIe
qdSw/NMXjVEwxwPa79DiYcT4okJL/V7bLy6KldaGLx3ArMnY17ZUsSP6FyaRPh3Q
0Dyp/QP2mAa3ufHWmK+RwVR+gCQ0qKqqqAbAXOJ8YXgDHTvUF1Kv42goQkuhpOTA
HXTo+xN6ddh9fzXpTwJHt83hVV2yuKyDL43whQ7dIBK1GY3R7HNEBbgwR2cUAv0b
zs3OoJ9EPjNb2wty/0v4aQLfRnURqpZrOnQeobEgi2LnLbjP3DK2QNY6i6HHcFmU
VQSc+xlP0m0NdsJrbQGlM3A+SVplgnnDv+UmBtgudbloBkpOoAaIK49ZrjaYQHqu
9Voh0LyklJMS+rOOxZsEgCLu+taNgzR5OJg+PxECm80UvQPJOIe/lRnYIaDHp92F
kN6Z5pgN+suuUdl4fOYd
=GPpB
-----END PGP SIGNATURE-----

--=-+mUA9Y0UCwFMPFPVgwxg--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
