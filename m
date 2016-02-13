From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH net-next v8 05/19] net: ethtool: add new
 ETHTOOL_GSETTINGS/SSETTINGS API
Date: Sat, 13 Feb 2016 01:49:09 +0000
Message-ID: <1455328149.2801.82.camel@decadent.org.uk>
References: <1455064168-5102-1-git-send-email-ddecotig@gmail.com>
	 <1455064168-5102-6-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-NCwJIfUL82hmdvCgSQ0U"
Cc: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eugenia Emantayev <eugenia-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Ido Shamay <idos-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Govindarajulu Varadarajan <_govind-KK0ffGbhmjU@public.gmane.org>,
	Venkata Duvvuru <VenkatKumar.Duvvuru-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org>,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	Ed Swierk <eswierk-FilZDy9cOaHkQYj/0HfcvtBPR1lH4CV8@public.gmane.org>,
	Robert Love <robert.w.love-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"James E.Yuval Mintz" <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
	Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>,
	David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>
To: David Decotigny <ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
	fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1455064168-5102-6-git-send-email-ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-NCwJIfUL82hmdvCgSQ0U
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-02-09 at 16:29 -0800, David Decotigny wrote:
> From: David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>
>=20
> This patch defines a new ETHTOOL_GSETTINGS/SSETTINGS API, handled by
> the new get_ksettings/set_ksettings callbacks. This API provides
> support for most legacy ethtool_cmd fields, adds support for larger
> link mode masks (up to 4064 bits, variable length), and removes
> ethtool_cmd deprecated fields (transceiver/maxrxpkt/maxtxpkt).
[...]

I previously asked you to include 'link' in the command names and
structure name. =C2=A0This would clarify that these are now only for link
settings and reduce the risk of confusion between old and new commands.
However, you didn't reply to that review. =C2=A0Do you have any objection t=
o
doing this?

Ben.

--=20
Ben Hutchings
Sturgeon's Law: Ninety percent of everything is crap.
--=-NCwJIfUL82hmdvCgSQ0U
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVr6Llee/yOyVhhEJAQptQxAAqHw6JCPN3b1UNtl5CkykMq9sgZ+j8VOi
9b6BaMefBawGFNaPzk6xQBpnwfrGdcofFw+r3Y+OThloB1NB5orhWTnX8citmnlA
zFuKYE0Si1YC23nlITS+n3U8xJnQKyjwN4jB+acYc3YqELGg6qXvLGQYYpRXKBa0
rwlYT13ZjTF9oar0dpEXJo9Y3uUsWDVnAeG1E3AAqel5llKzr0n+bUdjO76rdNMQ
/B2IOq2H09ufZdRKJl9Mtd0LrcvNXZzFepfRqW86kd9NqClwwLsHsinlUVttYaz2
I5DprGRLIC2CCh82aqLwBMqvnwcR2erOANIPdGpnHS8vUpkgCdClxEXujB3IOzcs
+CYF4FMZjjVZp0fsedds4hkTKdgn1ALKurMoyfWPKbzFBdgJR8qGbpzAdR2uz3Vg
+AzeRqLv9EP3VnctF9Cmndlmy0ycmpb1Vd3sU3x+2MNFy1lPavzmbXULtB1T+GsN
TRnfUfvWQ2T+dadHpqH+tVElNivQoiaKOpL2FVWUPZEs+0ngI9I74VKQuMG2RbBu
3EzolbI3XfCt+kMbvnkJuCXHdvt63OOcVGy6QBfQW+Hy64aUaDB7ojau+/3NJjwl
K9F+jJF07SRDWToWHNO2h98fnZt2/9dxazlELgwAnyU7PpK1RieS9huDeHvXG8Ge
QM9yzxMhV4s=
=aMKY
-----END PGP SIGNATURE-----

--=-NCwJIfUL82hmdvCgSQ0U--
