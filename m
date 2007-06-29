From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Fri, 29 Jun 2007 13:58:17 +0200
Message-ID: <1183118297.4089.44.camel@johannes.berg>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1179831825.4121.30.camel@localhost>
	 <1180258853.7707.53.camel@localhost.localdomain>
	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
	 <1181811576.5411.27.camel@localhost.localdomain>
	 <1181820510.4091.9.camel@localhost>
	 <1181869285.5411.39.camel@localhost.localdomain>
	 <1182178882.4063.11.camel@localhost>
	 <1182223964.5411.76.camel@localhost.localdomain>
	 <1182811210.6644.22.camel@johannes.berg>
	 <1182986681.5155.55.camel@localhost>
	 <1183023939.4769.76.camel@johannes.berg>
	 <1183115835.5156.37.camel@localhost>
	 <1183116527.4089.40.camel@johannes.berg>
	 <1183117692.5156.67.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-V75/SMRD/g5kiS7k2p1R"
Cc: Zhang Rui <rui.zhang@intel.com>, netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: hadi@cyberus.ca
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1183117692.5156.67.camel@localhost>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-V75/SMRD/g5kiS7k2p1R
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-06-29 at 07:48 -0400, jamal wrote:

> sure - if you rush you can make it into Daves 2.6.23; then both can
> conform at the same time.

Yeah, I'll have to see whether I can make that. If not, no big deal
either.

> > Ok :) Though I'm not sure I understood the suggestion of sending just
> > one TLV, what should I send?=20
>=20
> I meant when user space asks the controller "please tell me details
> about family X" you will always pass an id and name. Never just one.
> So why not just send that in a struct which has a id/name (as you
> already have defined in your current patch).

I'll have to look at the struct stuff again, but yeah, something like
that can be done.

johannes

--=-V75/SMRD/g5kiS7k2p1R
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGhPPZ/ETPhpq3jKURAh48AKCWzPqQS3QUltBYrt9d3LLZCZTuagCfZj13
JZhStUuR0faaWCBxoTL6/Zs=
=qsdg
-----END PGP SIGNATURE-----

--=-V75/SMRD/g5kiS7k2p1R--

