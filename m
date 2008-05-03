From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Sat, 03 May 2008 18:03:02 +0200
Message-ID: <1209830582.3673.8.camel@johannes.berg>
References: <20080501.024320.212547875.davem@davemloft.net>
	 <E1JrW9h-0001tI-00@gondolin.me.apana.org.au>
	 <20080501.034950.261408566.davem@davemloft.net>
	 <20080501.035335.216935614.davem@davemloft.net>
	 <1209639500.7067.0.camel@johannes.berg>
	 <20080501110341.GD7490@gondor.apana.org.au>
	 <1209818282.3987.23.camel@johannes.berg>
	 <20080503125940.GA26199@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-wvIaB8thTShjMNwj1ZpO"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080503125940.GA26199-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-wvIaB8thTShjMNwj1ZpO
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2008-05-03 at 20:59 +0800, Herbert Xu wrote:
> On Sat, May 03, 2008 at 02:38:01PM +0200, Johannes Berg wrote:
> >
> > Why, btw? It's not too hard to check the allocated size, no?
>=20
> Yes that would be a meaningful improvement although we'd need to
> audit/test this to make sure that we don't spam people's logs
> with it.

It does spam the log. A lot. And I don't know why, from this discussion
I only thought that it shouldn't.

johannes

--=-wvIaB8thTShjMNwj1ZpO
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASByMtaVg1VMiehFYAQINDA//ZR+DTv3VdTh/IXUTH+QtMzZC7+lSS1bO
6GZq0oejjSnZp7WWMROe+WADbSnuc6rIYQRGT8Ewu5CMNjEJoVi36W/rSF6Rl5Gl
/yVvitmhNiPWQfqFySuNnC3mFdH5Yh4/2Emk/7LMd5AeIN7QL7F33zJEZz6ds0Rt
ng6oWP8l5l/WsQncROQlmzmUw5Pji6dXuP0g62nHgkVotEUlK9j0nOiOBbR97/qd
5KDxjVaZy3nmVxusx3Cq/J8YX1byiimLin/z7NDWMeT9IMROEOLgKp5iis2b1rsr
ckKS4crvSIYzEXnes+W185JIsCu4JzVS/hhlneSVAzoLuldwdOU154LQunc89Vw/
jUmG/RPBVVOp1Q4rfBgadXtSu62iPl+xqTrH3cbC2i0sekBTqmv1YVIKlk4D0pXr
kbYpiIkfs+w/By9sHbHn5WCQfA7/BUkhf2cRTgMEZhYxOF5SFjjDDBZeXOy7C0aY
fk72COjO/lL5TQ9YFllT4aQTAjX8vhPVf6N/AAZALjHppFumDwhzQ5lV4fCkyMKs
vAcTADKqytGT8B5n84WDsZj9f2BcWS/tb6DoazgvHDt5jfRJNAyROKCkD3ory8Lu
ii5KEUX2TO7hDvQUbQSC2A6o12FopqdOchG7L3L6L/lwltKOAZz4p0mp1QAxPrpQ
nBNMBTT7De0=
=WMp4
-----END PGP SIGNATURE-----

--=-wvIaB8thTShjMNwj1ZpO--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
