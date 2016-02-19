From: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCHv2 3/4] ARM: tegra: use build-in device properties with
 rfkill_gpio
Date: Fri, 19 Feb 2016 19:03:54 +0100
Message-ID: <20160219180354.GA9911@ulmo>
References: <1453712629-143317-1-git-send-email-heikki.krogerus@linux.intel.com>
 <1453712629-143317-4-git-send-email-heikki.krogerus@linux.intel.com>
 <20160125121840.GA20452@ulmo.nvidia.com>
 <1453797724.2759.4.camel@sipsolutions.net>
 <1455825889.2084.16.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="zhXaljGHf11kAtnf"
Cc: Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>,
	Marc Dietrich <marvin24-Mmb7MZpHnFY@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1455825889.2084.16.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Feb 18, 2016 at 09:04:49PM +0100, Johannes Berg wrote:
> On Tue, 2016-01-26 at 09:42 +0100, Johannes Berg wrote:
> > On Mon, 2016-01-25 at 13:18 +0100, Thierry Reding wrote:
> > > =C2=A0
> > > Johannes, I assume that you'll want to take this through your tree
> > > because of the dependency? In that case:
> > >=20
> > > Acked-by: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
> >=20
> > I can, but I don't really care - perhaps you'd rather take the entire
> > series through your tree to get it into one place for Marc?
> >=20
> > In which case, you have my
> >=20
> > Acked-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> >=20
> > for the other 3 patches.
> >=20
> > Let me know which you prefer.
> >=20
> Did these patches get applied anywhere? Otherwise I'm willing to pick
> them up.

Might be easier for everyone if you took this one patch. My earlier
Acked-by still stands:

Acked-by: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>

--zhXaljGHf11kAtnf
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJWx1kGAAoJEN0jrNd/PrOhkOMP/0fKZyr0TyLPjFuGkoUR2735
0AM2cqT7FLaN4I44rMyKQj/tDyjPfoAdELazVOfv4WrfhkfzXx+sS2gnA9LBSwho
CC7y7jp8poQYFCb1s9PrMZMbiDpdW1SlS+A2jGAsAcDGNHanfxNtP6v0EvYdF469
LSeJvDsPZkWfy9+5+lBM8tCFw9ULWakS5eetUB2B4G7GFD5L/2cP9xmTm0tiysQ6
JZyEZAoQq7jNIhnI6UfJY0h2ZUJq3UHjnKOA9MQfaeVVsaR3oBcgtzGP9AwxBZgU
bi+AYGJgzP3WgqIFbGrGDHhdEzl8AOetartb+h23ebfpKmFO+AQ3ShtzDP/9FW/X
ftLWHhREFTkOg5WxuEIPQAfvJiYiSls1a+JYf5r9iX8MgpWec9GdmmcrvwcXYqVT
T1w15wftPUxBmIMrl5XNMcoUJIn2DatXeTX06Y85P13N7HigbXQY+nq1SjMClcul
qvSjmmp5NPiu/ZrVeOdsWFy6eWp1gZQBdCS7K1uY5Tn/9C7Y23bfopWw6ieaJ+UN
WQdI74VLoTCvaLj7jk2DdBu0RqO+tb4YAa8+xhYewAKhl57QrTw7T+IP1CVOlbE4
Stemsa/c/9jqnDhWcUUeNINzEq5BZXTSdCWATtuVjFdtIEjmJMTc2XhoVpSupxYd
oxs5jGAfRVlGFV26C6If
=pgXB
-----END PGP SIGNATURE-----

--zhXaljGHf11kAtnf--
