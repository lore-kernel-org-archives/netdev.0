From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Hidden SSID's
Date: Sun, 28 Jan 2007 22:28:37 +0100
Message-ID: <1170019717.30318.0.camel@johannes.berg>
References: <45BACB71.2080107@lwfinger.net>
	 <1169899689.25670.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-7eV2Czd/m46WiEPbCubL"
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:53590 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbXA2LBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jan 2007 06:01:42 -0500
In-Reply-To: <1169899689.25670.3.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-7eV2Czd/m46WiEPbCubL
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2007-01-27 at 07:08 -0500, Dan Williams wrote:

> I really, really don't know why ieee80211 uses <hidden>, but it's a pain
> in the ass and should NOT be done for d80211.  I don't know if we can
> ever remove it from ieee80211 though for backwards compat reasons.

Ugh. /me makes a note for the cfg80211/we compat layer. This is a
mess :(

johannes

--=-7eV2Czd/m46WiEPbCubL
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFvRWF/ETPhpq3jKURAn70AJ9QSFwwkllTFm7OpQoGncT3XFxE1QCdEjQ/
sjOsvlV49j/+ICaTY68S9sw=
=qURE
-----END PGP SIGNATURE-----

--=-7eV2Czd/m46WiEPbCubL--

