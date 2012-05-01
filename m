From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [E1000-devel] e1000e tx queue timeout in 3.3.0 (bisected to BQL
 support for e1000e)
Date: Tue, 01 May 2012 15:42:28 -0700
Message-ID: <1335912148.2656.11.camel@jtkirshe-mobl>
References: <CA+mtBx-K6-O3ea34kmn4LXtx73FqCHF16w7pBSq1fHNN+-DxCA@mail.gmail.com>
	 <4F91DB7B.7060601@candelatech.com> <4FA05153.1010903@candelatech.com>
	 <20120501.174914.654247970871851432.davem@davemloft.net>
	 <4FA05ED2.3030608@candelatech.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-oqHZODtgd3afLqXi7f/P"
Cc: David Miller <davem@davemloft.net>, john.r.fastabend@intel.com,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	therbert@google.com
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:8844 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753633Ab2EAWma (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 18:42:30 -0400
In-Reply-To: <4FA05ED2.3030608@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-oqHZODtgd3afLqXi7f/P
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-05-01 at 15:08 -0700, Ben Greear wrote:
> On 05/01/2012 02:49 PM, David Miller wrote:
> > From: Ben Greear<greearb@candelatech.com>
> > Date: Tue, 01 May 2012 14:10:43 -0700
> >
> >> On 04/20/2012 02:56 PM, Ben Greear wrote:
> >>> On 04/20/2012 02:21 PM, Tom Herbert wrote:
> >>>> Thanks John for pointers to those.  Ben, are you running a kernel
> with
> >>>> these patches?
> >>>
> >>> I just tested this on my e1000e and igb machine.  With these
> patches,
> >>> I can no longer reproduce the problem.
> >>>
> >>> So, please make sure those are queued up for 3.3 stable!
> >>
> >> Dave:  I think these patches below should go to 3.3 stable.
> >>
> >> They are not queued for stable yet as far as I can tell.
> >
> > I let the Intel developers handle -stable submissions for their
> > drivers.
>=20
> I don't think this is specific to their drivers.
>=20
> But, as long as _someone_ is pushing it to stable,
> it is fine by me.
>=20
> Thanks,
> Ben=20

I will take care of the stable submission's Ben.

Cheers,
Jeff

--=-oqHZODtgd3afLqXi7f/P
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPoGbUAAoJEOVv75VaS+3OcAQQAJdcp5DI4c06PPMvuqtaNm5p
zBsbkwb3qdvgaII716xncdPa1xLRiCKgA4372U6SdaVbP+QslTd+OnUctD/a3Mv0
o3tv68xRUSLv0ELu5QV6PajLOeE27DJqvE35/0sJvbPzeIlAF9wT2jENKwtZXKHy
tZwSJ2Ns8OnhpzHuHAOXqfrUH/xC5QEHp/oOj8sSxvJs+zOXz6v3JnioT/3IG4AR
q4S0eld4kFyhgFEGssHN9dAEvAew7UXhbPf56tATzB3hps4ki5b7lB7q5KYqFb+T
KoV1bR7JJGFAekASZPy086f2Lvs9DxPc+oMFT0UmDWNv5CpvdiZTAO/f34U1P3/S
FZhZcxqcvjHfPIF8CsyQMrSXZh0mIsCtRqCS1UMp3G9jfOeM+AcSMjHmjXybQ/55
tykqHt8ONOgDCaUccOEHm9IL4cBi9/LqG0JKIkfMoBdCFLX2XL1yGq7HFf6kkF34
STteuzntqYSBgkyM/SgBRIHffdwVi30n0kQAQqYIJ7zkKot95Jp9NQTPPjIIwOLh
QQ5KXMjUtsBZOnltE3Q9geSu5T5bZ9d0soFopMbGcoF0qYhkfmBDpLDVB6QgtILx
kfo+cDCm20U0K94RVU5xKXFad4Bh4FwJyRnOg30jXUwyWscgIBoHpwo0Ar5wLgKC
9ryct8U60kFXMuoyrDXB
=YcZM
-----END PGP SIGNATURE-----

--=-oqHZODtgd3afLqXi7f/P--
