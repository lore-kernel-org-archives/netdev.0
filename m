From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH stable v3.2 v3.4] ipv4: disable bh while doing route gc
Date: Mon, 20 Oct 2014 13:23:28 +0100
Message-ID: <1413807808.31953.24.camel@decadent.org.uk>
References: <6c3d6eca5d6a15c01393b010f2116bd169477c5a.1413215324.git.mleitner@redhat.com>
	 <20141013.135127.1915115817707962111.davem@davemloft.net>
	 <1413774581.31953.12.camel@decadent.org.uk>
	 <20141020.002308.1276148768580405795.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-s6NDbksCwJCnO4z2wMMN"
Cc: mleitner@redhat.com, stable@vger.kernel.org,
	netdev@vger.kernel.org, hannes@stressinduktion.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:41855 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751906AbaJTMXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 08:23:39 -0400
In-Reply-To: <20141020.002308.1276148768580405795.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-s6NDbksCwJCnO4z2wMMN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-10-20 at 00:23 -0400, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Mon, 20 Oct 2014 04:09:41 +0100
>=20
> > I've appplied this and the previous two patches mentioned ('ipv4: move
> > route garbage collector to work queue' and 'ipv4: avoid parallel route
> > cache gc executions').  But I didn't get the other two from you.  The
> > last batch of networking fixes I received and applied was dated
> > 2014-08-07, and the next one I've seen is dated 2014-10-11 and has
> > nothing for 3.2 or 3.4.  Did I miss one between these?
>=20
> I'm at the point where I'm personally not going to go back more than
> four releases, anything more than that is rediculous.
>=20
> And this time that was 3.17, 3.16, 3.14, and 3.10

OK.  I appreciate all the work you've done to backport to 3.2, but would
also have appreciated an explicit note to say you were dropping the
earlier versions.

Thanks, Ben.

--=20
Ben Hutchings
[W]e found...that it wasn't as easy to get programs right as we had thought=
.
... I realized that a large part of my life from then on was going to be sp=
ent
in finding mistakes in my own programs. - Maurice Wilkes, 1949

--=-s6NDbksCwJCnO4z2wMMN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVET+wee/yOyVhhEJAQraew/8CpgiKzhEPjo33cXLapcmETsODTFHW+GN
5ZDkzU/QPg1UNgZRkQaZcDOuIMS1Ch2KNmVQ4AvNcExaQXla+bwisCY7xK+JJ+cv
ocngYX7UjBBkbJYKFKGX1FNF2TfEnpgpzY/un7Qxg40tko/V+zBXcKfnMZPzUmZA
vuSnCjDEJ7y/u5NIyPXf2dIKIfp7Z3FSWPspXl2aJuQCzJNKdL3FZuVaLGNVtVqQ
dQUCffXkNR3csy5l/GuIRJJYFLTnEAMAihknelX2ZrVc+BduLPrg765xEEmvGG8L
+cvYhJPNu0fCMg6wPOFuqKE+cD7eoUPtYpWQJNMZW8LOQdt7ldwUeVnsPkXKgu6h
DrN7RKoUKqqbAvF0tOGkJTMJPYBKgBzbmPu5Cpsh3E8EL/faBdbkbn3RxwQTccxe
KO5I+EeYHHkU6j9BD9ZemUwz7HQSarVQjY8hT6qajFriSQgdXeCT1sd8jN0OF6om
x/XeYZxj15te4bYw6DWOHlFTkMbl5sDQAJLMb/8oKEiceASaQxdLzuPb6rM1lDhb
oQJ9hQK6yAg+26MhadTdz31SZbrocy2doA8AOaXmbTRmpCCyF5ioQiMRvE/5N+kV
xsnU5V3yLInrhPWN+WyOLqa8v2TZ+svljzTz/oJPLd25T0xvWeyuZ5/ksJF+GVos
Zt5w9Qdq2K0=
=ubMd
-----END PGP SIGNATURE-----

--=-s6NDbksCwJCnO4z2wMMN--
