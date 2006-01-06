From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: State of the Union: Wireless
Date: Fri, 06 Jan 2006 12:31:24 +0100
Message-ID: <1136547084.4037.41.camel@localhost>
References: <20060106042218.GA18974@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-SX8kqMC7fAVHD94rzeC8"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752249AbWAFLbc@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20060106042218.GA18974@havoc.gtf.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-SX8kqMC7fAVHD94rzeC8
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2006-01-06 at 12:00 +0100, Michael Buesch wrote:

> * "master" interface as real device node
> * Virtual interfaces (net_devices)

I didn't want to spam the netdev wiki with this (yet) so I collected
some more structured things outside. Anyone feel free to edit:
http://softmac.sipsolutions.net/802.11

I'll move that content to the netdev wiki if anyone else thinks it would
be a good way forward to start with requirements, API issues and
similar.

Until we get there, we'll fix up softmac to make it usable for most
people in basic station mode without any kind of virtual devices, which
will need some slight changes to the current ieee80211.

johannes

--=-SX8kqMC7fAVHD94rzeC8
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (SIP Solutions)

iQIVAwUAQ75VCqVg1VMiehFYAQIWRQ//e3w0C0uKX3DsS/r+2Yk7czllBH7xQEJ9
Rnm5g6dBq39fEzkRKEMMsW8WLDbstsCxP+UMWBeChw9U91hoKnfx2X2DfPcaQZSO
7EWVSpzb/h44Bji9tp7IeQkZgLnkMkEzdYL0O9VKbrznptVz04NX7etEpakJFzsG
HXF3Is0sOLT//YaF5dM3zKMy44jb+v0XOWt09dHBA98VBFmfTniqB4f6kjsMv85J
dUfc/RiTlRKRq1IvT7m7gNalrN5ds5sb72My1sPUow99maEUkgYruaBoi7aunWOF
1+ZmOPDP/7Ts3vmww8pNKk8zaMFOBHegYm0IBKmPkJnwz84SFk3N3ZcUjsFye/Ie
CX28QMkI6M8K3E7zpMa5d8bFEbgC3NChWYF0xjJGhlFks72tqNBCgoHX72Uu4+w0
Eu+id+sHJzbD49IYglGONnGXRqDSvkIX/gVlZC+Id42WU5PnIvcTcqlwEhYOyVfp
hbf1JS2y6XwsAGk1tZ2a5m9t8Zc83FFQDMk8DTyVgfmCRKN8JJVqxbwcKUK3ggXA
S1EVEkfil8Ot/n7/F/PQ8TcYWPgwksw/hKvVAgacBRKEZXLRM030UmRN8VdcQnIc
4REw4+ANX103Y40HNBsqNKU5HQkOAjTYLFEmXqfHXOo+uRHAl7JzskFXOFQZE6pr
XDpHb2eTG3U=
=8lph
-----END PGP SIGNATURE-----

--=-SX8kqMC7fAVHD94rzeC8--
