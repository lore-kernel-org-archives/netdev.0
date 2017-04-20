From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 00/15][pull request] 10GbE Intel Wired LAN Driver
 Updates 2017-04-18
Date: Thu, 20 Apr 2017 01:44:22 -0700
Message-ID: <1492677862.3627.1.camel@intel.com>
References: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
         <20170420052515.GA77954@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-ijD+9J/6TCLk/w6V6aSa"
Cc: davem@davemloft.net, netdev@vger.kernel.org, nhorman@redhat.com,
        sassmann@redhat.com, jogreene@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:62289 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938696AbdDTIob (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 04:44:31 -0400
In-Reply-To: <20170420052515.GA77954@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ijD+9J/6TCLk/w6V6aSa
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2017-04-19 at 22:25 -0700, Alexei Starovoitov wrote:
> On Tue, Apr 18, 2017 at 04:01:50PM -0700, Jeff Kirsher wrote:
> > The following are changes since commit
> > 4116c97689b9b1732ac5b68afd922406f9fc842e:
> > =C2=A0=C2=A0 Merge branch 'ftgmac100-batch5-features'
> > and are available in the git repository at:
> > =C2=A0=C2=A0 git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/nex=
t-
> > queue 10GbE
>=20
> Nothing against this set of commits,
> but I saw ixgbe xdp support in there pending for few months.
> Now it's gone. What happened?

XDP is in the next series of patches, per Dave, we need to keep patch
series smaller to help in revue.  Next series will contain what you are
looking for, just need to get this up before I can push the next
series.
--=-ijD+9J/6TCLk/w6V6aSa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAlj4dOYACgkQ5W/vlVpL
7c6aKg//b5ELyYYZghFhymR//7bi+Er2hEHMCycIIDA4zvo2gMgW5LKXm4wg0XMB
Phutj5DONnCMza1Ga1YPCWf2eFbf8WqcILW6Ztf5zkXC/qCfEGKom5tqYJ2qr1PA
wFRHSr1n0XV6erQ7+lWbIJ4BWFVGNGhSdX2AtpXC5ujWyIzyr4wEJX9coHBV0JUY
wlrfSUZSbFcOPTbZWebzDTHS9Tu5MKBtWKAAveDoXJVFqGNAma7Jq0ZApXPpooY5
mFPo6bkLG7IUIilyq1iXbfyI79tO+krX1Z6snfyXkhhsbtJ1BDmXNYYsP1A+XOEn
nnfX7Z3SfX0jtZCZ2xB9SzTtQsjNmpYK/t4wkOsr9XX8FTDMKn8dLCYbCns0KQWa
3dpy0RS2tEOE49bkkUTJAlrsytcAKIaD1F8U9rrug3g2FmzvCfGnvNl+msUah0ah
mxkBCz+I4BJRYHe9fwHO/yqF8M0OoJXiA8CU21GbhBYzJBk3BvjmIMxcK9IFJnQ8
bIvIaR3Zxq3P4TaacmnYchMD7vPwRa5sM08nH2dIvfLDCLcMokeR6aGOFpZzCpuc
4HUTQ12u5XDZ87JMT75Flh3BHttD91bStgtnRQBq/Ryi5/xN6PI3CeASUzih6x97
00PNqYkiXk8cHzvuBae3RxaCh0038+VjQLIXAR4YZTO67HLdkQs=
=yajc
-----END PGP SIGNATURE-----

--=-ijD+9J/6TCLk/w6V6aSa--
