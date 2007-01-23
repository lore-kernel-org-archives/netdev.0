From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Tue, 23 Jan 2007 17:54:33 +0100
Message-ID: <1169571273.3649.12.camel@johannes.berg>
References: <20070116185524.GA5681@dmt>
	 <20070117141103.0e468bf4@griffin.suse.cz>
	 <1169046072.2750.10.camel@localhost.localdomain>
	 <1169047134.9175.49.camel@johannes.berg>
	 <1169055788.2550.44.camel@localhost.localdomain>
	 <1169056884.9175.66.camel@johannes.berg> <20070122112613.GA3038@dmt>
	 <9e4733910701220720x47506091m357cbf9e5deb3903@mail.gmail.com>
	 <1169566914.3649.4.camel@johannes.berg>
	 <9e4733910701230818g13dc82a2kf0972b8543db449f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-pYB8rckSVznpsRg/+Y+H"
Cc: Marcelo Tosatti <marcelo@kvack.org>,
	Dan Williams <dcbw@redhat.com>, Jiri Benc <jbenc@suse.cz>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:44976 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932255AbXAWQz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 11:55:26 -0500
To: Jon Smirl <jonsmirl@gmail.com>
In-Reply-To: <9e4733910701230818g13dc82a2kf0972b8543db449f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-pYB8rckSVznpsRg/+Y+H
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-01-23 at 11:18 -0500, Jon Smirl wrote:

> Is the 802.11s Draft 1.0 spec publicly available yet? It is supposed
> to be making changes at the very lowest MAC layers. It will be hard to
> be compatible with that from user space.

Good point, it's not possible to implement this without changes to the
MAC.

> The software doesn't have to be written but there should be at least
> some design work done on how 11s should fit into the existing world
> for both a firmware and software implementation. I'd hate to see a
> different implementation for each vendor and another one for the
> software stack.

Then we'll first have to find those vendors interested in actually
changing their MAC to allow .11s I guess.

johannes

--=-pYB8rckSVznpsRg/+Y+H
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFtj3J/ETPhpq3jKURAtorAJ9OguU0XDujBKrvam3Ubv6DHMzBWQCdGwXG
QUBtMvNpth7t3AtN1MzGfdo=
=9Hmp
-----END PGP SIGNATURE-----

--=-pYB8rckSVznpsRg/+Y+H--

