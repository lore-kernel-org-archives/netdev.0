From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: pull request: batman-adv 2012-05-11
Date: Sat, 12 May 2012 00:10:25 +0200
Message-ID: <1580622.xq0LFHtR2u@bentobox>
References: <1336738892-7401-1-git-send-email-ordex@autistici.org>
	<20120511.180144.174337959525316777.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1771440.M4XkGvE5Cm";
	micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20120511.180144.174337959525316777.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org


--nextPart1771440.M4XkGvE5Cm
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Friday, May 11, 2012 06:01:44 PM David Miller wrote:
> From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
> Date: Fri, 11 May 2012 14:21:17 +0200
> 
> > this is a fixed version of the pull request issued on 2012-05-09.
> > 
> > Comments introduced in this patchset are not following the net-tree
> > guidelines. Another patch changing all the already existing comments
> > will follow later.
> > 
> > New exported functions follow the new name convention we discussed so
> > far. A patch renaming all the existing exported functions will follow.
> Pulled, but you have to cleanup the namespace on lots of other
> functions too.
> 
> For example, the packet receive handle register/unregister routines
> you added in this series as well.
> 
> Go through the entire batman-adv stack, and if the function or data
> object is not static, make sure it has a batadv_*() prefix.

The patches for this are posted on the batman-adv mailinglist [1]. I am 
currently splitting this large patch for easier consumption.

Thanks,
	Sven

[1] https://lists.open-mesh.org/pipermail/b.a.t.m.a.n/2012-May/007062.html
--nextPart1771440.M4XkGvE5Cm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPrY5RAAoJEF2HCgfBJntGFgYP/RhKTOYvfvP6z9tZa0V7Qz0Z
7SfNKpEf06TEk/lnEnh63U7oqywakQnfrJWvC7Nuarj7Wg8vZs011u4FCNr16a53
lnpwDxgvTQKT1hxm6WejOJylUulqpxRx1Mdf1U5NFwfrjh4fuLcetYS0cI7TJhaI
YNY61aCQ4Xru79TBQ9HYzfA4jeX3WXYJIIhGDsTSHG1jfwGHzMLn2N3FPhwUT9Bz
55CWRsUSipXPprSr9abnTqvkSuNGj28eZ8poKU5TeOdZwhoNpLEDRSmaB9TNVPoO
9ihu/zcW3FL5TERnTQXIY38/ySxPtzYIMTG9sK8X9Bs+AlksClkepg+IZwCo2iXA
vOytqJ9pOmTw1FUtzd1Kt0bTiOo9LvPwV9NELlCt7hrzXeEgO9D4OkcFBbynOt+R
cGfBWRVoWb6fAnQuH2zvcMXrVhdbhqf83js9kUNwzZ8o9t2LQMPJhKzOdrr8Y1xc
pfxaH3EC/2G3dOBTXvCF9y+qyUKPiqnDqYttFpLnk/onb0V5i16+4OgX3xlYVyLo
62l9gX6OzYothYrj+hxASIvr131bHO/EgWpAQ98v1hO3giDUkDiXIQ8leWx7qOn2
YNQCXu3rUmw/0iquzVabgStXZm27DiW/B5N2iooQLYNCQyy3lKbFI1ywD9O5FS3v
2ZxhxwS9BTy+9uM2agP5
=KsYI
-----END PGP SIGNATURE-----

--nextPart1771440.M4XkGvE5Cm--
