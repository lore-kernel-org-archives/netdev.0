From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: CONFIG_KMOD breakage in next kernel
Date: Mon, 25 Aug 2008 10:28:48 +1000
Message-ID: <20080825102848.9b28da36.sfr@canb.auug.org.au>
References: <s5h3akzwtki.wl%tiwai@suse.de>
	<1219256165.3502.10.camel@johannes.berg>
	<200808251013.58975.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__25_Aug_2008_10_28_48_+1000_rMIZ0B7B=RBV.Dz/"
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Takashi Iwai <tiwai@suse.de>, linux-next@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	video4linux-list@redhat.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:58430 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751805AbYHYA27 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Aug 2008 20:28:59 -0400
In-Reply-To: <200808251013.58975.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Mon__25_Aug_2008_10_28_48_+1000_rMIZ0B7B=RBV.Dz/
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Rusty,

On Mon, 25 Aug 2008 10:13:58 +1000 Rusty Russell <rusty@rustcorp.com.au> wr=
ote:
>
> For today, I'll pull out the CONFIG_KMOD removal.

Does that mean you want me to revert "remove CONFIG_KMOD" from your tree
for today's linux-next build?

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__25_Aug_2008_10_28_48_+1000_rMIZ0B7B=RBV.Dz/
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkix/MAACgkQjjKRsyhoI8yA5ACfVZAfQ2Zdbqg5kcNPnLfSGw9X
9wkAoJZz9vHpyyGfUWiyRo3xCD54XvnW
=mRl0
-----END PGP SIGNATURE-----

--Signature=_Mon__25_Aug_2008_10_28_48_+1000_rMIZ0B7B=RBV.Dz/--
