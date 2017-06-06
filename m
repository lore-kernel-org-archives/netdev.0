From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH] net: mvpp2: do not bypass the mvpp22_port_mii_set
 function
Date: Tue, 6 Jun 2017 16:38:27 +0200
Message-ID: <20170606143827.GB22618@kwain.lan>
References: <20170606133615.20747-1-antoine.tenart@free-electrons.com>
 <20170606154535.3e87bafb@free-electrons.com>
 <20170606135148.GA22618@kwain.lan>
 <9ef70606-0918-fc4f-535b-dd1fc3475cb6@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="qlTNgmc+xy1dBmNv"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        netdev@vger.kernel.org, linux@armlinux.org.uk,
        gregory.clement@free-electrons.com, mw@semihalf.com,
        davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:40704 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751579AbdFFOij (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 10:38:39 -0400
Content-Disposition: inline
In-Reply-To: <9ef70606-0918-fc4f-535b-dd1fc3475cb6@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--qlTNgmc+xy1dBmNv
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Florian,

On Tue, Jun 06, 2017 at 07:24:35AM -0700, Florian Fainelli wrote:
> On 06/06/2017 06:51 AM, Antoine Tenart wrote:
> > On Tue, Jun 06, 2017 at 03:45:35PM +0200, Thomas Petazzoni wrote:
> >=20
> >> I am wondering if we shouldn't Cc: stable as well. I don't think we
> >> have seen issues on our side because U-Boot does the necessary
> >> initialization, but people using other bootloaders might have issues.
> >=20
> > Yes, that might be safer to cc stable. I'll do this as well.
>=20
> David queues network patches for stable provided that you submit those
> against his "net" tree [1] and there is an appropriate Fixes tag (which
> Thomas provided).
>=20
> [1]:
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/D=
ocumentation/networking/netdev-FAQ.txt#n114

That's good to know!

Thanks,
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--qlTNgmc+xy1dBmNv
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJZNr5jAAoJEFxNi8it27zYmaoP/j5kpNa5N3p8JAgYmDf/03S9
b/jaXiM/Uj7ZAxqfQTpvugioLGK12BTyD0uYVR6ckhPL9Z64YA3VeIxs8JuKWk5I
vqn5965usdMYLKcl67tadw3yODRuaH8kXTLkaiGWdkZdjMWK+W0BVeUIdJd47VSR
KwI5J9FRj7HFkPxh4JCE52pMNW71KSi5ZHCz+AhufpNVU6QP5evsO0VKbxrxyj20
E1STT1BLbpOwaVQ7Mz9/OsvRm87CRxlbdHsT5WQGIjWpE/XtYytcdGE5bBmYhuBf
OdAJ1ikMgFF+JsRfe7d9DnCEDQ1S0DWYg0zChUBgQmv3IhLDumoADfySMKDjfw5M
JbRVrJqq6f1Zl8y50b4vElSwBycy026F6SF0g1AWDJrbID2waNIkQ0uWyuTvbtuS
4qWTejuj39gnB9ECLmds58FFNp9cnLpLpuP7y41JZjDlh3D/K81uVLnCBvivws7V
h4Lwdyj0UpYz8hy+ANRk+wsQUUk24bDUMxNIlh4icz7fBNzM06upvxp/pVclUqbl
BKWUpBIs0lE0migrzMTKhM5ReGGioSkJQWTN5YYWLb0XAnKJDAyqM+afPmlK9WqX
olwlAeuyWITDY34afZNXbMZp2CEJjEJ5/6mkYYcaXUlZybCStjIqc8A3SpZiIeGy
xFwOW5hrAnk8me8BYzQK
=+ism
-----END PGP SIGNATURE-----

--qlTNgmc+xy1dBmNv--
