From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] udp: dynamically size hash tables at boot
 time
Date: Wed, 07 Oct 2009 03:47:34 -0700 (PDT)
Message-ID: <20091007.034734.42113251.davem@davemloft.net>
References: <4ACC1C73.1010506@gmail.com>
	<20091006.222935.231081303.davem@davemloft.net>
	<4ACC6F87.1050306@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41602
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758778AbZJGKrj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2009 06:47:39 -0400
In-Reply-To: <4ACC6F87.1050306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 07 Oct 2009 12:37:59 +0200

> David Miller a =E9crit :
>>=20
>> That's incredible that it's been that low for so long :-)
>>=20
>> Bug please, dynamically size this thing, maybe with a cap of say 64K
>> to start with.  If you don't have time for it I'll take care of this=
=2E
>=20
> Here we are.
 ...
> [PATCH] udp: dynamically size hash tables at boot time

Looks good to me.

I'll let this sit for at least a day to get some review from
others.

Thanks!
