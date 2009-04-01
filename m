From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Wed, 01 Apr 2009 17:11:42 -0400
Message-ID: <49D3D88E.3090009@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3B64F.6070703@codemonkey.ws> <20090401204039.GR18394@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig5B3D49DB3603766B6B86079F"
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:50841 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752653AbZDAVJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 17:09:30 -0400
In-Reply-To: <20090401204039.GR18394@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig5B3D49DB3603766B6B86079F
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Chris Wright wrote:
> And more stuff in the kernel can come at the potential cost of weakenin=
g
> protection/isolation.
>  =20
Note that the design of vbus should prevent any weakening...though if
you see a hole, please point it out.

(On that front, note that I still have some hardening to do, such as not
calling BUG_ON() in venet-tap if the ring is in a funk, etc)

Regards,
-Greg


--------------enig5B3D49DB3603766B6B86079F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknT2I4ACgkQlOSOBdgZUxlm+QCfWbYHbRE/jHWmK/swQMFNn6Wd
s/gAn2NdG+6yAYa0ohldbHbcl+h00t2f
=Y5ov
-----END PGP SIGNATURE-----

--------------enig5B3D49DB3603766B6B86079F--
