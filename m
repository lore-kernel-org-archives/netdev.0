From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net 0/7] mlx4: Bug fixes and cleanups
Date: Wed, 15 Feb 2012 08:03:58 +0100
Message-ID: <1329289438.2555.46.camel@edumazet-laptop>
References: <4F3A8DB5.3020703@mellanox.co.il>
	 <20120214.143023.281327914225614215.davem@davemloft.net>
	 <74A0102445410646AFACC089FD94803A5CEEACB5@MTLDAG02.mtl.com>
	 <20120214.152238.470074857804516115.davem@davemloft.net>
	 <953B660C027164448AE903364AC447D25D0B68A1@MTLDAG02.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yevgeny Petrilin <yevgenyp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:36629 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756851Ab2BOHEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 02:04:05 -0500
Received: by wics10 with SMTP id s10so302129wic.19
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 23:04:04 -0800 (PST)
In-Reply-To: <953B660C027164448AE903364AC447D25D0B68A1@MTLDAG02.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 f=C3=A9vrier 2012 =C3=A0 06:54 +0000, Yevgeny Petrilin a=
 =C3=A9crit :
> >=20
> > > Some of the patches fix very harmful memory leaks and corruptions=
=2E
> >=20
> > Then submit the patches properly, don't mix cleanups in there if it=
 matters so much to you.
>=20
> We will split the series in 2 parts, 1 for net and the other for net-=
next
>=20
> Yevgeny
>=20

Too late, all patches already in net-next

You should re-submit for net tree patches that need to .
