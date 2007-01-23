From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Tue, 23 Jan 2007 16:41:54 +0100
Message-ID: <1169566914.3649.4.camel@johannes.berg>
References: <20070116185524.GA5681@dmt>
	 <20070117141103.0e468bf4@griffin.suse.cz>
	 <1169046072.2750.10.camel@localhost.localdomain>
	 <1169047134.9175.49.camel@johannes.berg>
	 <1169055788.2550.44.camel@localhost.localdomain>
	 <1169056884.9175.66.camel@johannes.berg> <20070122112613.GA3038@dmt>
	 <9e4733910701220720x47506091m357cbf9e5deb3903@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-XeA/eANLX4qdszA4/qEZ"
Cc: Marcelo Tosatti <marcelo@kvack.org>,
	Dan Williams <dcbw@redhat.com>, Jiri Benc <jbenc@suse.cz>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:32953 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932939AbXAWPmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 10:42:54 -0500
To: Jon Smirl <jonsmirl@gmail.com>
In-Reply-To: <9e4733910701220720x47506091m357cbf9e5deb3903@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-XeA/eANLX4qdszA4/qEZ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-01-22 at 10:20 -0500, Jon Smirl wrote:

> What is the general solution for 802.11s?

None yet.

> I'm working on an embedded
> design that would benefit from 11s support and I'd rather not have to
> roll my own mesh implementation in user space.

Well, there is no mesh implementation that I'm aware of, you'll want to
stick it along with the userspace MLME into wpa_supplicant.

> I'd also like to get an
> idea of what kind of hardware I need to design onto my board given
> that the 8388 is not available general consumption. My system has
> plenty of power and CPU available so a softmac type 11s solution is
> the most cost effective. It seems to me that the design of a software
> based 11s stack should be coordinated with the 8388 firmware one.

It should, but afaik no one is really working on it either way.

johannes

--=-XeA/eANLX4qdszA4/qEZ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFtizB/ETPhpq3jKURArijAJ4zy2YL0h2MgyguorW/B5OSbOFR8gCghnw9
plbJjHgrl0dkFtuCjNGIFhY=
=Usvm
-----END PGP SIGNATURE-----

--=-XeA/eANLX4qdszA4/qEZ--

