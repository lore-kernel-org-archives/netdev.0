From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] ACPI: export acpi events via generic netlink
Date: Thu, 05 Jul 2007 10:35:41 +0200
Message-ID: <1183624541.3818.2.camel@johannes.berg>
References: <1182224403.5411.84.camel@localhost.localdomain>
	 <200707031545.16787.lenb@kernel.org>
	 <1183550487.3812.14.camel@johannes.berg>
	 <1183623847.8961.45.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-YYWdq1lpkbAornz9WL6G"
Cc: Len Brown <lenb@kernel.org>,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>,
	netdev@vger.kernel.org, hadi@cyberus.ca
To: Zhang Rui <rui.zhang@intel.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1183623847.8961.45.camel@localhost.localdomain>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-YYWdq1lpkbAornz9WL6G
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-07-05 at 16:24 +0800, Zhang Rui wrote:

> I missed the discussion about the multicast issues.
> You don't need to reserve a family and group ID for ACPI. I'll rework
> this on your patches.:)

I don't want to hold you, don't worry, I can handle it as well.

> But I don't know when these mutlicast patches can be merged while I hope
> the function of exporting ACPI event via genetlink can be added ASAP.
>=20
> I'm okay to hold off on this patch if you think the multicast patches
> can be merged soon. Or else I tend to apply it first and send an
> additional patch together with your patches later.

I personally think it's ready to go and haven't received any further
comments, but maybe something will come up still. I'll wait a few days
and then repost as an actual .23 submission.

johannes

--=-YYWdq1lpkbAornz9WL6G
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGjK1d/ETPhpq3jKURAgSLAKCqtD5DTqlrlHNQUJ7+g9Ns0Qgb2wCfWDr9
aoGcbSLQSpeQ8nU6L8nofEc=
=nmBt
-----END PGP SIGNATURE-----

--=-YYWdq1lpkbAornz9WL6G--

