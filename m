From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] net: add priority field to pktgen
Date: Thu, 18 Nov 2010 10:43:36 -0800 (PST)
Message-ID: <20101118.104336.179929345.davem@davemloft.net>
References: <20101117051228.19479.8267.stgit@jf-dev1-dcblab>
	<1289971637.2732.83.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40716
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760127Ab0KRSnL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Nov 2010 13:43:11 -0500
In-Reply-To: <1289971637.2732.83.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 17 Nov 2010 06:27:17 +0100

> Le mardi 16 novembre 2010 =E0 21:12 -0800, John Fastabend a =E9crit :
>> Add option to set skb priority to pktgen. Useful for testing
>> QOS features. Also by running pktgen on the vlan device the
>> qdisc on the real device can be tested.
>>=20
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.

This will be useful for stressing things like VLAN qos I guess
:-)
