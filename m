From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: Recent wireless breakage (ipw2200, iwconfig, NetworkManager)
Date: Mon, 05 Mar 2007 12:20:51 +0100
Message-ID: <1173093651.6131.47.camel@johannes.berg>
References: <20070304220857.GH23311@waste.org>
	 <1173051564.6131.13.camel@johannes.berg> <20070305002550.GI23311@waste.org>
	 <20070305011729.GB7681@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-WaY/ydGDzBbpcLWjiA3+"
Cc: Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, akpm-3NddpPZAyC0@public.gmane.org
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070305011729.GB7681-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-WaY/ydGDzBbpcLWjiA3+
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2007-03-04 at 17:17 -0800, Greg KH wrote:

> > > This is due to the recent sysfs restructuring I think. IIRC the fix i=
s
> > > to upgrade hal to a current git version.
> >=20
> > If that's the cause, the fix is to back out whatever was done to break
> > userspace. Breaking userspace is not ok. Upgrading from 2.6.x to
> > 2.6.x+1 should not entail replacing substantial parts of userspace,
> > especially with NOT-EVEN-FRAKKING-RELEASED-YET CODE.=20
>=20
> I should not have broken any userspace if CONFIG_SYSFS_DEPRECATED is
> enabled with that patch.  If that is enabled, and that patch still
> causes problems, please let me know.

Yeah, sorry for not mentioning that in my original email and the
discussion it stirred.

johannes

--=-WaY/ydGDzBbpcLWjiA3+
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF6/0T/ETPhpq3jKURAiozAJsGdNBKnO4F5KILsz5xkFeI1guIhQCgu4Ab
ZLbtATQiHXpB5fnsD/JwaV8=
=93wK
-----END PGP SIGNATURE-----

--=-WaY/ydGDzBbpcLWjiA3+--
