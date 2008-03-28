From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Subject: Re: [PATCH 0 of 5] IPv6: Fix temporary address support
Date: Fri, 28 Mar 2008 01:32:21 +0100
Message-ID: <20080328003221.GE8574@ens-lyon.fr>
References: <patchbomb.1206305168@pirzuine> <20080327175839.GB8574@ens-lyon.fr> <20080328.031240.97295681.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, pekkas@netcore.fi, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pilet.ens-lyon.fr ([140.77.167.16]:33911 "EHLO
	pilet.ens-lyon.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752511AbYC1Ac0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 20:32:26 -0400
Content-Disposition: inline
In-Reply-To: <20080328.031240.97295681.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2008 at 03:12:40AM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20080327175839.GB8574@ens-lyon.fr> (at Thu, 27 Mar 2008 1=
8:59:06 +0100), Benoit Boissinot <benoit.boissinot@ens-lyon.org> says:
>=20
> > On Sun, Mar 23, 2008 at 09:46:08PM +0100, Benoit Boissinot wrote:
> > > This is the set of patches I needed to make IPv6 temporary addres=
ses
> > > work in my setup.
> > >=20
> > > [snip]
> > >
> > > Please review and consider applying.
> >=20
> > [sorry for being too impatient]
> >=20
> > Do you think there's a problem with those patches ? Or is it just a
> > problem of reviewer time/availability ?
> >=20
> > I'd really like not to miss the merge window for them.
>=20
> We have no merge window for bug fixes.
> I'll take a look at it, anyway.

Thank you! I've fixed the patches for the comments you've sent.

Once someone finds the time to review the last two patches, I'll resend
them.

Do you have an opinion about my PS (DESYNC_FACTOR not being random) ?

regards,

Benoit

--=20
:wq
