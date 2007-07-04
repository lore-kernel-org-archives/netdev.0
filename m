From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] ACPI: export acpi events via generic netlink
Date: Wed, 04 Jul 2007 14:01:27 +0200
Message-ID: <1183550487.3812.14.camel@johannes.berg>
References: <1182224403.5411.84.camel@localhost.localdomain>
	 <200707031545.16787.lenb@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-v8ZmBqZoVw8uz68gP1X+"
Cc: Zhang Rui <rui.zhang@intel.com>, linux-acpi@vger.kernel.org,
	netdev@vger.kernel.org, hadi@cyberus.ca
To: Len Brown <lenb@kernel.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <200707031545.16787.lenb@kernel.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-v8ZmBqZoVw8uz68gP1X+
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-07-03 at 15:45 -0400, Len Brown wrote:
> Thanks for including the demo program, Rui, it works for me (tm).
>=20
> Applied -- with the incremental patch below, which I think
> is correct because the only caller is bus.c, which is part of
> the base kernel, not a module.

Dang, mail crossing :)

Are you open to reworking this on top of my multicast patches that I
hope to get in soonish, or should I respin my multicast patches to
ensure ACPI has a stable family and multicast group number?

johannes

--=-v8ZmBqZoVw8uz68gP1X+
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGi4wX/ETPhpq3jKURAiYOAKCjbHp01r13B6vksUuWB5UOKeIY4QCeOoTQ
P9Ieefg5jkIGK3sP8+E9QTQ=
=cyOB
-----END PGP SIGNATURE-----

--=-v8ZmBqZoVw8uz68gP1X+--

