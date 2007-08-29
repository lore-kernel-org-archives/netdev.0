From: Joe Perches <joe@perches.com>
Subject: Re: net-2.6.24 rebased
Date: Wed, 29 Aug 2007 16:47:07 -0700
Message-ID: <1188431227.6062.114.camel@localhost>
References: <20070828.175404.23012909.davem@davemloft.net>
	 <20070828.175922.70219802.davem@davemloft.net>
	 <1188430440.6062.110.camel@localhost>
	 <20070829.164130.31655965.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4556 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750877AbXH2XrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 19:47:14 -0400
In-Reply-To: <20070829.164130.31655965.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-08-29 at 16:41 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Wed, 29 Aug 2007 16:34:00 -0700
>=20
> > On Tue, 2007-08-28 at 17:59 -0700, David Miller wrote:
> > > I pushed this fix into net-2.6.24 just now, thanks again.
> >=20
> > This tree doesn't compile for me defconfig

CC      drivers/net/forcedeth.o
drivers/net/forcedeth.c: In function =E2=80=98nv_probe=E2=80=99:
drivers/net/forcedeth.c:5158: error: =E2=80=98nv_napi_poll=E2=80=99 und=
eclared (first use in this function)
drivers/net/forcedeth.c:5158: error: (Each undeclared identifier is rep=
orted only once
drivers/net/forcedeth.c:5158: error: for each function it appears in.)
make[2]: *** [drivers/net/forcedeth.o] Error 1
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2


