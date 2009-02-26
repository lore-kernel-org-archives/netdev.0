From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2009-02-23
Date: Thu, 26 Feb 2009 00:36:00 -0800
Message-ID: <1235637360.29050.16.camel@johannes.local>
References: <20090223192659.GB3553@tuxdriver.com>
	 <1235457113.4455.89.camel@johannes.local>
	 <20090224.235510.30497146.davem@davemloft.net>
	 (sfid-20090225_085557_984527_FF340420)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-A5Ldsm3E1PHy4+xMvr7e"
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090224.235510.30497146.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (sfid-20090225_085557_984527_FF340420)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-A5Ldsm3E1PHy4+xMvr7e
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-02-24 at 23:55 -0800, David Miller wrote:
> From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> Date: Mon, 23 Feb 2009 22:31:53 -0800
>=20
> > On Mon, 2009-02-23 at 14:26 -0500, John W. Linville wrote:
> >=20
> > > Johannes Berg (10):
> > >       mac80211: disallow moving netns
> > >       mac80211: fix aggregation for hardware with ampdu queues
> > >       mac80211: split IBSS/managed code
> > >       genetlink: introduce pre/post methods
> >=20
> > Hold off on this please, the genetlink patch here introduced a problem
> > with locking and I'm going to rework/fix that.
>=20
> Ok.
>=20
> In fact it's better this way, since now John can send me the pull
> request after the net-2.6 --> net-next-2.6 merge conflicts are
> resolved.

Now I just have to get around to fixing it, it's proving to be harder
than I thought, and I don't have much time right now.

johannes

--=-A5Ldsm3E1PHy4+xMvr7e
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJplRuAAoJEKVg1VMiehFY9w0P/iK7rE1CjPNwyXMwi96CwTlU
jUAcmUNt0VG9vGlD8w/IJTiALbSLob+1Xy7LAepnV1fYyK7DWnLEYpcQDqRzoWqQ
t/3Vb6yGKU8aqJCMvqT9wJ5mjq1qf2dyvowvjdKdNNwi+twPDj81LJ3MenZjlv/M
btnCn66/Wr2SFJoLI6+tEKQY1jWQB4ZtsuCZXE5+ohZD6WV/nojfJB45/6ydWFCx
T7qXh9uwulL+SKr86sr7FWXRuzZTljEtWoGpK99PkaRG6RBW4OiVJwgZn+Uc1iA1
0QHniukFvyiV5Ssh7lbdflZBXzhjpoS6PH0sSMJQjhy1zPwwmdz9E2XMnD27Hp+U
p2w0cjl/ZDIoKLvzpZOLvWtPznSlPdrdAr/sCYm3X9kpXpr4XNA0ELHpQXQlz3YL
qjFr5OpBtxZ58LW1NZniAzaEmeAHso5d9CzXmhSzghC7b/8OoPk5FIp/103oV7DC
A4B2IGMtRWPSwet9TbtfzNLZif1qvveOh1z1arY2t9MP5amwPbsT9GNAo0vR9yJB
dvrTlskvjGwi1CQZRno/x1yesIZG+WXhnZrxVTbv1iBHx4Gj/Z1635yVogb4zBjs
puDaxaDYRCc7t9XGtZ8BwMeaOT1pXWfVU5AnPS/tONvmWY1A1zsH/MuLNCikQ5z1
X5nAYe/hxz1PFbbxRru8
=KeLo
-----END PGP SIGNATURE-----

--=-A5Ldsm3E1PHy4+xMvr7e--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
