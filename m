From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] net: stmmac: fix bad merge conflict resolution
Date: Fri, 6 Sep 2013 14:19:29 +1000
Message-ID: <20130906141929.2f30c62de4eb5c6ad9d3f699@canb.auug.org.au>
References: <20130905.163725.106795517693348522.davem@davemloft.net>
	<1378429301-19964-1-git-send-email-olof@lixom.net>
	<20130905.225817.700066425182547791.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__6_Sep_2013_14_19_29_+1000_y258LkJM6Squ_HDq"
Cc: olof@lixom.net, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130905.225817.700066425182547791.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__6_Sep_2013_14_19_29_+1000_y258LkJM6Squ_HDq
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Thu, 05 Sep 2013 22:58:17 -0400 (EDT) David Miller <davem@davemloft.net>=
 wrote:
>
> From: Olof Johansson <olof@lixom.net>
> Date: Thu,  5 Sep 2013 18:01:41 -0700
>=20
> > Merge commit 06c54055bebf919249aa1eb68312887c3cfe77b4 did a bad conflict
> > resolution accidentally leaving out a closing brace. Add it back.
> >=20
> > Signed-off-by: Olof Johansson <olof@lixom.net>
> > ---
> >=20
> > This breaks a handful of defconfigs on ARM, so it'd be good to see it
> > applied pretty quickly. Thanks!
>=20
> Looks like Linus applied this, thanks Olof.

And I cherry-picked it into linux-next for today.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__6_Sep_2013_14_19_29_+1000_y258LkJM6Squ_HDq
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJSKVfWAAoJEECxmPOUX5FEVQ8P/A5fyR41e1cgYZgVo2w+XMVW
LkflqemSr5GD3I+lune+4yqmUsGX9qI27UjiHpNU1pWda0gXXatn16iF6f3sXp/L
HK03rhXS3TkUouvOwLBi/QDQD5DyBBy7vNn8qzledfQDn1oBeR4vWeZyeXKaLL47
fQoxLd9GB4Ex/vEBkn5XqxY7BzG2FWrAEuu1XE9lhbe9ZOkagXXzykka7+ix2ofa
dj8cck+OtRAXV1usvR+EYUMW3UpnHpvhKDJx5josOBiqHrN2yJGVNGgu+im0WL7V
uWwJfKA2LSJdySaMe3Na5T99kBa2JZzfyan/bf52owKuw5GPgWo8zETn3euey9Xb
43+D4ORKxX/RjZLMS7lH3CBa72DSSzEFLwK2JIxQkEkqp5OVzwGTP1yPsrtHC2JJ
0SSPElpD8U90XFq1zd00UQ9Ei1siNFireJW0c0ivFv3jyhQBME0JELkQdzK0hT3L
h5FbjytxkcH6sa7GWXsyLCofzMW4+cLKQIzyCXAzGjBny2dzWno1CBsz7dd28KfD
vWRBSwKqJjSUnpSRGcDfWZA/dCcBekxsfSDYpStc2dBEcIL8m/hFSNTY0dM/4SYL
zx55bwqsEWMZWYybjMGyPq89doLEcf4F6pwoZ2aFzdhjqdghjdWgI2x21MTrXLtp
/+77/dJ9rwmVZnkjrjP8
=MLHa
-----END PGP SIGNATURE-----

--Signature=_Fri__6_Sep_2013_14_19_29_+1000_y258LkJM6Squ_HDq--
