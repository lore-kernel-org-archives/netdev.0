From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv8 1/2] Interface group: core and netlink part
Date: Thu, 03 Apr 2008 13:35:59 -0700 (PDT)
Message-ID: <20080403.133559.37298080.davem@davemloft.net>
References: <1204812239968-git-send-email-panther@balabit.hu>
	<20080306.111519.46454329.davem@davemloft.net>
	<47D137AB.9040305@balabit.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: panther@balabit.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42026
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750757AbYDCUf7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Apr 2008 16:35:59 -0400
In-Reply-To: <47D137AB.9040305@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Laszlo Attila Toth <panther@balabit.hu>
Date: Fri, 07 Mar 2008 13:40:11 +0100

> David Miller =EDrta:
> > If that's all it is, userland can record such mappings
> > in the filesystem or elsewhere such that multiple
> > applications can work with and maintain the relationships.
> > There is zero reason to add this bloat to the kernel in
> > such a case.
>=20
> Yeah, without the netfilter rules this would be unnecessary in the=20
> kernel but it depends on it.

Ok, I'm convinced, please resubmit your patch against
net-2.6.26

Thanks!
