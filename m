From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: [PATCH] wl1251: add a missing spin_lock_init()
Date: Thu, 31 Aug 2017 20:57:19 +0200
Message-ID: <20170831185718.GA31245@amd>
References: <20170831065204.GA17812@amd>
 <87y3q0q7ln.fsf@kamboji.qca.qualcomm.com>
 <20170831144743.GA21261@amd>
 <20170831.103305.1809212990680774811.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="W/nzBZO5zC0uMSeA"
Cc: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
        xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170831.103305.1809212990680774811.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
> Date: Thu, 31 Aug 2017 16:47:43 +0200
>=20
> > Dave, Linus -- can you still take the patch?
>=20
> Pavel, please do not bypass maintainers like this.
>=20
> It's really rude, and if you do things like that instead of
> trying to work properly with us, your relationship with
> these maintainers will suffer in the long term.

Do you mean I'm being rude to Kalle, or rude to you?

In the part you snipped, Kalle asked me to do just that:

# I'm not planning to submit pull requests to 4.13 anymore. If you think
# this is so important that it needs to be applied in the last minute (I
# don't) you could always try to convince Dave to take it directly.

=2E.and as I still believe patch should go in, that's what I did.

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--W/nzBZO5zC0uMSeA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmoXA4ACgkQMOfwapXb+vLwzQCfUH/sTzIQGI368mHh7goYMqyr
Y0MAoJHYk44NU6GToYbDVRI7RU9aBN7S
=bFME
-----END PGP SIGNATURE-----

--W/nzBZO5zC0uMSeA--
