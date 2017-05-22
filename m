From: Sebastian Reichel <sebastian.reichel-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
Subject: Re: [PATCHv4] wlcore: add wl1285 compatible
Date: Mon, 22 May 2017 17:21:12 +0200
Message-ID: <20170522152112.634mnsv65lryrmkp@earth>
References: <20170505141553.2605-1-sebastian.reichel@collabora.co.uk>
 <8737bx5jgr.fsf@purkki.adurom.net>
 <20170522.103010.1779800840743690143.davem@davemloft.net>
 <87wp99t0hj.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="du4yizhtxamxnsy6"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org,
        marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87wp99t0hj.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--du4yizhtxamxnsy6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Mon, May 22, 2017 at 05:44:24PM +0300, Kalle Valo wrote:
> David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:
> > From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
> > Date: Mon, 22 May 2017 12:28:20 +0300
> >
> >> Sebastian Reichel <sebastian.reichel-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org> writes:
> >>=20
> >>> Motorola Droid 4 uses a WL1285C. With differences between the
> >>> chips not being public let's add explicit binding for wl1285
> >>> instead of relying on wl1283 being very similar.
> >>>
> >>> Reviewed-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> >>> Acked-by: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
> >>> Acked-by: Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>
> >>> Signed-off-by: Sebastian Reichel <sebastian.reichel-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
> >>> ---
> >>> Hi Dave,
> >>>
> >>> I previously send this in two patches, but its hard to apply without
> >>> requiring multiple kernel releases (the driver must be updated before
> >>> the DTS change). Since the actual change is not very complex Marcel
> >>> Holtmann & Tony Lindgren suggested, that I send this directly to you
> >>> in a single patch for inclusion into 4.12. This also means, that the
> >>> remaining series can be queued normally for 4.13.
> >>=20
> >> I noticed that Dave set this patch to Awaiting Upstream state on his
> >> patchwork:
> >>=20
> >> https://patchwork.ozlabs.org/patch/759042/
> >>=20
> >> Which makes me suspect that he is waiting me to apply this (as I
> >> normally apply wlcore patches). Dave, should I actually take this patc=
h?
> >> What do you prefer?
> >
> > Anything that touches wireless drivers I defer to you, yes.
>=20
> Thanks, I'll take it then. Not sure why Sebastian was suggested to
> submit this patch via your tree in the first place.
>=20
> https://patchwork.kernel.org/patch/9713645/

Thanks. The idea was to get into early 4.12-rc to avoid merge
conflicts in the droid 4 *.dts during 4.13 cycle. This strategy
obviously failed :)

-- Sebastian

--du4yizhtxamxnsy6
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEE72YNB0Y/i3JqeVQT2O7X88g7+poFAlkjAeUACgkQ2O7X88g7
+pqAkw/+Np0Af9vglPve6xzMSNtounaL6ru4YJ+0TFBahLhz5eLAx6F4BoRH6Jou
PfZNh2HK5fQwA0IDqE2h3rb7jQlx0AYQKbV+uHbkDUTZ5Omaug0tNyEeM2fzWsul
PdG13QdAQmcs9J5+0tiNy75aXsA93vOjgD2481n0Tp7h1I+zBkiug3A07UOSWJLI
wX/qdOo0nsGs/yBygDJAZHJWkk7ZDT11JySdeL5WnPuEwlZ8Oe8AnqJPFQ1BQKUA
yEwaiFD5f1x0DJgwrni5QPmeCMQjDo6IRTuQ158pppXWk8IQTD7ssivVsIfpE0rC
scky41E4FgfTJLmWFrPn78Akm6zmxGITVTFJamkoveKFKcsagsi8NpyJmA9ACQ6l
dtHP/WH1Ux14EpCmuVdczAP57Xb8QK9WKRPiTglZ+3eyhhbAuCZVqvnN6VuEqGOG
ZAwlfYQn3HpMeaB24tkndTpA5cJruEl8sFF0xBBsrmPvX50XOzBwzyP1TDLAl8cw
ZM+gWMmv4JTIqqiEGDE0MBsy+AHxvme4xGHCiBDGwOcW5DgP2NQs5e8JYQC21oQw
ZRLG2Du0ypVqqxggcbAcpHf+rttZ9kF+aP8nIkvrC3qmwD3cqS6E/vstTNgosVtg
yG3+IhmuETmc9hx5q2x6sBn6+k7no+knp4kjK6SnHOGzDDPveFw=
=FzJZ
-----END PGP SIGNATURE-----

--du4yizhtxamxnsy6--
