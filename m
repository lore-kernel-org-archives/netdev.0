From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2.6.20] kobject net ifindex + rename
Date: Thu, 01 Mar 2007 01:37:46 +0100
Message-ID: <1172709466.11911.7.camel@johannes.berg>
References: <20070228012741.GA3988@bougret.hpl.hp.com>
	 <20070228153617.GA5670@suse.de>  <20070301002647.GA7045@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ozk2WigRgUkGJe/Sb/Yv"
Cc: Greg KH <gregkh@suse.de>, Jarek Poplawski <jarkao2@o2.pl>,
	"David S. Miller" <davem@davemloft.net>,
	Linux kernel mailing list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: jt@hpl.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:33661 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274AbXCAAik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 19:38:40 -0500
In-Reply-To: <20070301002647.GA7045@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ozk2WigRgUkGJe/Sb/Yv
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-02-28 at 16:26 -0800, Jean Tourrilhes wrote:

> +	/* This function is only used for network interface.
> +	 * Some hotplug package track interfaces by their name and
> +	 * therefore want to know when the name is changed by the user. */

Right now, that's true, but wireless is going to start using
device_rename pretty soon as well. Could you rephrase this comment?

johannes

--=-ozk2WigRgUkGJe/Sb/Yv
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF5iBa/ETPhpq3jKURAkmNAJ9oDQyYy34aGHVIh9nLlz5pq/rokwCfYGpR
09Dq5+hrGtmTKTX8XIQOWUw=
=J5vm
-----END PGP SIGNATURE-----

--=-ozk2WigRgUkGJe/Sb/Yv--

