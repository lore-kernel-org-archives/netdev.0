From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH stable 3.4.y 0/2] gso/gro forwarding changeset
Date: Sun, 06 Apr 2014 14:16:20 +0100
Message-ID: <1396790180.22689.122.camel@deadeye.wl.decadent.org.uk>
References: <1393061606-5422-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1ipNL0PR3CDZn34x7upB"
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58241 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751502AbaDFNQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Apr 2014 09:16:31 -0400
In-Reply-To: <1393061606-5422-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1ipNL0PR3CDZn34x7upB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-02-22 at 10:33 +0100, Florian Westphal wrote:
> Dropped the 2nd patch of the series (addition of netif_skb_dev_features)
> for the longterm-backport.
>=20
> The forward path will use 0 feature mask instead.
> I think it is preferable to keep the changeset smaller for these kernels.
>=20
> Should apply to 3.2.y as well.
>=20
> Let me know if you disagree and would like to have netif_skb_dev_features
> backport too.

I've queued these up for 3.2, thanks.

Ben.

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.

--=-1ipNL0PR3CDZn34x7upB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU0FTpOe/yOyVhhEJAQpnFhAAv9zzpYIP4tLUNTF4onSrWIuaA/ivUMcO
S2R5Xd/sx+LEs2Qjy9ubg7/gAC4XUgGsL+fDwYlHBJK0AEmQnux5JzU2ypHXG8+r
RgbMjBPJMoe2A9nj1cWFVw28mw/oomgEWAiXyECeT3Y+7hFLsVgsy5QUr1/k7DtL
0dKwIAx0QDlCa1S4cjlcHwrz0I36WBVv9U2XRpMrhLDAxndlEuukZO6Xt7J2vzwb
Wf5cjIfm5/pz1nsgnvsN4hvDJGtOGKTwhNikkElxbD6UUkN7oQABdLkQ4WBGI8yf
NwS2bD7+zyQfM9C0w7adusgHeMUWbNtIFg7glsv60tIw3PkXz4v1ZHDUjJ7LdpPV
YhS9ogsHwSIxV8Q+E7yA9FHEKqAfM+saeLOZE2z5e5CBdy/M/sIWWTAcd4EIdt9N
ZrPOHKuw8Y440Uc8oxhb8+fYkToSs+kYTGzYZyH/fP3pzY1EuPp04B2UhVndB7Qm
x45eD+RwHNXh+d/9bDCYMmDNoBIie+sS9yfLaBQ3huGwzKDsK2qU/+mLRBz2C36j
jRWUA2laNmTdzFYcX9uUMqrJIOwDgi7Bfq+oOcMBgJSPEbjEMHkK3/Emk48tdjFX
j9fGB+jB1sgKMChs8I5pz3ac/zT9cZqZ+NoHeN/NZhLdmE6ovUW7TK6ya5T1tom2
pCRPAlXhYfU=
=7LbJ
-----END PGP SIGNATURE-----

--=-1ipNL0PR3CDZn34x7upB--
