From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 01:56:59 -0700 (PDT)
Message-ID: <20081029.015659.223371561.davem@davemloft.net>
References: <490795FB.2000201@cosmosbay.com>
	<20081028.220536.183082966.davem@davemloft.net>
	<49081D67.3050502@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, benny+usenet@amorsen.dk, minyard@acm.org,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	cl@linux-foundation.org, a.p.zijlstra@chello.nl,
	johnpol@2ka.mipt.ru, christian@myri.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49791
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752776AbYJ2I5Z convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2008 04:57:25 -0400
In-Reply-To: <49081D67.3050502@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 29 Oct 2008 09:23:03 +0100

> David Miller a =E9crit :
> > From: Eric Dumazet <dada1@cosmosbay.com>
> > Date: Tue, 28 Oct 2008 23:45:15 +0100
> >=20
> >> I will submit a new patch serie tomorrow, with :
> >>
> >> Patch 1 : spinlocks instead of rwlocks, and bug spotted by Christi=
an Bell
> >>
> >> Patch 2 : splited on two parts (2 & 3) , one for IPV4, one for IPV=
6,=20
> > I very much look forward to this :-)
> > I like these changes and can't wait to add them to net-next-2.6
>=20
> Thanks David, please find first updated patch 1

Applied, please (re-)send the current version of patch 2 as well.

Thanks.
