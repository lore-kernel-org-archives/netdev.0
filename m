From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [RFC v2 00/10] HFI Virtual Network Interface Controller (VNIC)
Date: Wed, 11 Jan 2017 11:16:55 +0200
Message-ID: <20170111091655.GZ7218@mtr-leonro.local>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161215091226.GC811@mtr-leonro.local>
 <20161215145212.GA29116@phlsvsds.ph.intel.com>
 <380b05bf-a18e-1f20-7e8e-10b61f77dec7@redhat.com>
 <20170109075104.GV15685@mtr-leonro.local>
 <20170110033954.GA53664@knc-06.sc.intel.com>
 <20170110081402.GH7218@mtr-leonro.local>
 <20170111090539.GA78804@knc-06.sc.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="IUSVF+LtaR4kWxuH"
Cc: Doug Ledford <dledford@redhat.com>,
        "ira.weiny" <ira.weiny@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        dennis.dalessandro@intel.com
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:52662 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756004AbdAKJQw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Jan 2017 04:16:52 -0500
Content-Disposition: inline
In-Reply-To: <20170111090539.GA78804@knc-06.sc.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--IUSVF+LtaR4kWxuH
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 11, 2017 at 01:05:39AM -0800, Vishwanathapura, Niranjana wrote:
> On Tue, Jan 10, 2017 at 10:14:02AM +0200, Leon Romanovsky wrote:
> > On Mon, Jan 09, 2017 at 07:39:54PM -0800, Vishwanathapura, Niranjana wr=
ote:
> > > We are also looking into Jason=E2=80=99s suggestion to make hfi_vnic =
interface to
> > > the bottom driver a generic interface. This will include moving some =
of the
> > > netstack interfacing to the bottom hfi1 driver.
> >
> > Great, do you have rough estimation when will it be posted on the ML?
> >
> > Thanks
> >
>
> Hi Leon,
>
> I am currently doing some prototype on this. I will respond with the
> interface definition first once I have it solidified. RFC v3 with
> implemetion will be later.

It makes sense.
Thanks

>
> Niranjana
>
>

--IUSVF+LtaR4kWxuH
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlh1+AcACgkQ5GN7iDZy
WKdjiQ//aUxtTbM9nCSas6rRow2OhozmjQy2jai1S+sDpL+vQ6/Ylr5Xg2nWA9ay
+BzscJ3mCx2jrwhvCwDiy7B25kKLe1iopyeHw44hjVv78sdyORCAzD1BuNhH9MZf
c0x9JaJzZLp/13wQcM6aDLu0ERkVPG+llfiBkq1KUERAaRIESPrRRY3hbnuiPXrt
Gk+3bkhIg5MeK+E6pd873k5ySQ3PL01i/VORLeftgs50uDY1EZ34iK2h2d3bcqEi
Mw7Plpx46d57GI1h9Jc1ummHp+K7HHMQ6c/Fnwohdf9XEaZGTOkmpH5nFs1Ziurj
vnSduuP09HKYSDqn7aZhgEji0VvssG30jCtaMOxBDUD2EaSiBWo5WqYdR/AwlYZd
CLkBNprLpXZOzd+XTAzIDmdO2TpADTwgf1G3VlFdT6Yd/LWrn4yQgx4J8ieHM1/2
KRhZuH9pPXDwjfFdmTGjfuOsYJnPk2+DXN6haQhepWQRcdnpd0s/CBoadqidLCXM
K9tkZyIvkwcdvUQ9fpmAGMvYDUfdwPlPJorvC0pAfhoAUXdHdRqiMhGWiZeNHkpq
eyeKQaIv23C5fRSztSnE6fMcSbHbBiXIpA2EiDwO4Br/AXvOCQGGjq3Z0kdOLISq
QXWfgZEtuSHpB3NQtr18YbO1KFqZOBSLaH48cQrxuZs1MdEPrqY=
=z2yx
-----END PGP SIGNATURE-----

--IUSVF+LtaR4kWxuH--
