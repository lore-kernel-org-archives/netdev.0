From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: pull request: wireless-2.6 2008-08-18
Date: Tue, 19 Aug 2008 14:27:39 +1000
Message-ID: <20080819142739.aee40461.sfr@canb.auug.org.au>
References: <20080817185605.GC30679@tuxdriver.com>
	<20080817.151251.204370966.davem@davemloft.net>
	<20080818151551.GA5524@tuxdriver.com>
	<20080818.211632.251536898.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__19_Aug_2008_14_27_39_+1000_TomPPdzDZIhuXn4u"
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:47791 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991AbYHSE1x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 00:27:53 -0400
In-Reply-To: <20080818.211632.251536898.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Tue__19_Aug_2008_14_27_39_+1000_TomPPdzDZIhuXn4u
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Mon, 18 Aug 2008 21:16:32 -0700 (PDT) David Miller <davem@davemloft.net>=
 wrote:
>
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Mon, 18 Aug 2008 11:15:51 -0400
>=20
> > (Revision 2, commit references in changelogs augmented w/ subject text.)
> >=20
> > Here is the latest round of wireless fixes for 2.6.27.  The silliest one
> > is the one from Adrian Bunk, which applies the gcc-related fix to ath9k
> > again because there were two identical pieces of code to fix -- I guess
> > I didn't get the joke *facepalm*...
> >=20
> > I don't think there is anything else remarkable, although I think we fix
> > a couple of the current regressions on LKML.
>=20
> Pulled thanks John.
>=20
> Assuming nothing shows up in my build testing I'll push this out
> to kernel.org shortly.

Just as an extra datapoint, this has already merged into linux-next and
built fine for a powerpc ppc64_defconfig and x86_64 allmodconfig this
morning.  And yesterday's linux-next had the previous version of these
patches (only commit comment differences as far as I am aware) and the
build logs are at http://kisskb.ellerman.id.au/linux-next .

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__19_Aug_2008_14_27_39_+1000_TomPPdzDZIhuXn4u
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkiqS7sACgkQjjKRsyhoI8zOiACdGJnVh2E+UkQOhHwYCqwdwjTv
R4UAoICe1FKj5b0I4N133k2IYqT/0feV
=qC4V
-----END PGP SIGNATURE-----

--Signature=_Tue__19_Aug_2008_14_27_39_+1000_TomPPdzDZIhuXn4u--
