From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [2.6 patch] make sta_rx_agg_session_timer_expired() static
Date: Mon, 21 Apr 2008 11:13:48 +0200
Message-ID: <1208769228.26186.58.camel@johannes.berg>
References: <20080421084751.GI26897@cs181133002.pp.htv.fi>
	 (sfid-20080421_094826_042377_F92BCDE4)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-JnziNcEOnDCqZ1Wdo2UF"
Cc: Ron Rindjunsky <ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080421084751.GI26897-Aar9JVdAhcRoA3hw4S0G5QR5/fbUUdgG@public.gmane.org> (sfid-20080421_094826_042377_F92BCDE4)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-JnziNcEOnDCqZ1Wdo2UF
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-04-21 at 11:47 +0300, Adrian Bunk wrote:
> sta_rx_agg_session_timer_expired() can now become static.
>=20
> Signed-off-by: Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Good plan, thanks.

johannes

--=-JnziNcEOnDCqZ1Wdo2UF
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASAxay6Vg1VMiehFYAQIRng//YI2newZI/2KVaSA9T7MepevSleFr0mKk
6RRN8M5PO1CmMVbShy1UMRP0QBjQxu5YmMqCUHb36fcI0WzzI6f4kSxthPQ2JeFo
rKTElV1dj7lasq9UwC3ElOqIFNvweDM7F2UnHp02glYgDgCXw3bkCEMToFVBwQDU
on2ePmXGFwF90pof+CeLsDWClS8k2p177O+LfKYduCkVy5IhXIBGH74OeeKdvyH1
AwoXYMKLk9n3wepzQcU/H6fAZbx90J21a/G0X6sSTxfSHNxqaU4DuDhBcPmlzQOh
yc/thcKfv7zBJSOpp9jUyQwhR00vGHUKj33fQmooQ+ilqujzxQBKN7RPkOIo+h/v
SJnYuGOY34rPDhjZZPxNtiOsdLZPloHVqwGRxH2DLtogcWugsOnPO0vwJc55Rco7
vHO9GaWCooStEta3Ix4Zc+9rEnOtfe58+yzP39oYoqLE2lwT/OYg1kLs4tTryiVF
D26ukDrYqa4OtGpxoHH8yYhTI54dd8dO/1UZ+PRsjIXVyCFmqRRNm78c7jamnFzb
xd9DDAKaUiEfrZnssDblt99OZAJrSl8iroVSehUCZq/OscxrkCLcOHvFwVEv4SmV
WTbT32AcBQ2PRoqzwc3Gy9SOS+I+LrQnG+cs4prUXBzNl5mkAAyMSI3XySNw5Sjv
emkJUVRfbWQ=
=aUgR
-----END PGP SIGNATURE-----

--=-JnziNcEOnDCqZ1Wdo2UF--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
