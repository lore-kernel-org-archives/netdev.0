From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Inconsistent lock state in ipt_do_table
Date: Wed, 18 Aug 2010 15:44:18 +0200
Message-ID: <1282139058.2194.84.camel@edumazet-laptop>
References: <4C6ACAB5.2090507@csr.com>
	 <AANLkTimWeZHQk3Z8MTa1ajhP1-CJV_nSwxNvEVuMfAoK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Vrabel <david.vrabel@csr.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63058 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120Ab0HRNoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 09:44:24 -0400
Received: by wwi17 with SMTP id 17so852134wwi.1
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 06:44:22 -0700 (PDT)
In-Reply-To: <AANLkTimWeZHQk3Z8MTa1ajhP1-CJV_nSwxNvEVuMfAoK@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 ao=C3=BBt 2010 =C3=A0 21:26 +0800, Changli Gao a =C3=A9c=
rit :
> On Wed, Aug 18, 2010 at 1:45 AM, David Vrabel <david.vrabel@csr.com> =
wrote:
> > Is this related to or fixed by
> >
> > http://marc.info/?l=3Dlinux-netdev&m=3D128202731626693&w=3D2
> >
>=20
> I am afraid not. Please try this patch:
> http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dpat=
ch;h=3D001389b9581c13fe5fc357a0f89234f85af4215d
>=20
>=20
>=20

Or use latest Linus tree.




