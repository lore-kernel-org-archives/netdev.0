From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 6/6] d80211: add sysfs interface for QoS functions
Date: Thu, 14 Dec 2006 16:04:14 +0100
Message-ID: <1166108654.3161.9.camel@johannes.berg>
References: <20061214040302.GA10689@mail.intel.com>
	 <20061214122339.37fc6b6d@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-MUnGbcmGvA031sbRd7MV"
Cc: yi.zhu@intel.com, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:53234 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932818AbWLNPsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 10:48:10 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061214122339.37fc6b6d@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-MUnGbcmGvA031sbRd7MV
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2006-12-14 at 12:23 +0100, Jiri Benc wrote:
> On Thu, 14 Dec 2006 12:03:02 +0800, Zhu Yi wrote:
> > The sysfs interface here is only a proof of concept. It provides a way =
for
> > the userspace applications to use the advanced QoS features supported b=
y
> > d80211 stack. The finial solution should be switched to cfg80211.
>=20
> So... what about implementing that into cfg80211? :-)

I agree, we should put this into cfg80211/nl80211 from the start. It's
not really hard to still have some things over WE and start using
cfg/nl80211 now.

johannes

--=-MUnGbcmGvA031sbRd7MV
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFgWfu/ETPhpq3jKURArBzAJ4+LDaM+oJEyyMuQh7dJ6QjZzjEhwCgnlVE
hT8wrD4YRh6sAgE0MEaI6Ws=
=8e8t
-----END PGP SIGNATURE-----

--=-MUnGbcmGvA031sbRd7MV--

