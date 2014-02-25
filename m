From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC v2 2/4] net: enables interface option to skip IP
Date: Tue, 25 Feb 2014 02:01:59 +0000
Message-ID: <1393293719.6823.148.camel@deadeye.wl.decadent.org.uk>
References: <1393266120.8041.19.camel@dcbw.local>
	 <20140224.180426.411052665068255886.davem@davemloft.net>
	 <1393286520.6823.123.camel@deadeye.wl.decadent.org.uk>
	 <20140224.191238.921310808350170272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-YYrQ2oDAg0I7CCTJmDT8"
Cc: dcbw@redhat.com, mcgrof@do-not-panic.com, zoltan.kiss@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140224.191238.921310808350170272.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-YYrQ2oDAg0I7CCTJmDT8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-02-24 at 19:12 -0500, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Tue, 25 Feb 2014 00:02:00 +0000
>=20
> > You can run an internal network, or access network, as v6-only with
> > NAT64 and DNS64 at the border.  I believe some mobile networks are doin=
g
> > this; it was also done on the main FOSDEM wireless network this year.
>=20
> This seems to be bloating up the networking headers of the internal
> network, for what purpose?
>=20
> For mobile that's doubly inadvisable.

I don't know what the reasoning is for the mobile network operators.
They're forced to do NAT for v4 somewhere, and maybe v6-only makes the
access network easier to manage.

I doubt the extra header length hurts that much on a 3G or 4G network.

Ben.

--=20
Ben Hutchings
Everything should be made as simple as possible, but not simpler.
                                                           - Albert Einstei=
n

--=-YYrQ2oDAg0I7CCTJmDT8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwv5l+e/yOyVhhEJAQpXUA/9HUG2G2LIDPmo09FoOGCUKQ3ak6vf9ZgB
WCkn4sqbfANNxloU8AZT/rnWzcaU5GwlTm4b3XCEmiU9pDCOfZDDa81a2j20MnqI
MHY61c19Vg7SIeQ46TbVGlUOvn13XkHeqYulQIfgW6EvUnVugVog1/MHdagsTpjM
wJSHN1y8NegK07aO9KkEMM16APT6nE1bZ8tVTB5iwaX3b23ZBY/Z5P7Zk70gcbLt
4VoaNmzv76O5SQJ82KQjbpuI+ZNYYXstG6ZIfRUEcFbBEZc0+6LQoEkEK9LOJcSk
4khGycBNemZlQleyhs35WdYde9ZCHkOhHOBzYmmBiuVdy8wwm+rYSEr0RNpBnMji
6cltOYeIX0pXC0FVf7ooeQLrZhYhEmo2AM0qCOqsOt6waTQ54zBmb/PNK2aJUKhJ
Gvkb/5aNQrAiOV5XWkrzT+jXRAVd8JYHQYE/nSBHwtdk+mdukXLdlBz4FaB8o5I/
peG/3Xvo+J74WEHLOGJhvKRgS6N6WZ7rurLUX4O4EiSZD90HoSdQBp7yhaasjfEw
65x2pf+ZM99XwS+41dVj9TCc14KjRdbt13FeJaSbz2GD+WpcOIRRdR2/0LL7/Swl
lYpVB21XTFhrERBL9qRt1X43sHnqCHgDL1+UfJLmCZ9JXHaQ1vqdkTv9BTTgkeee
zdXHXl0KAsg=
=rbWU
-----END PGP SIGNATURE-----

--=-YYrQ2oDAg0I7CCTJmDT8--
