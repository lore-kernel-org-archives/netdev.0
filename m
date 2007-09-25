From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Tue, 25 Sep 2007 19:53:04 +0200
Message-ID: <46F94B00.3060006@trash.net>
References: <20070925122029.15989.0@janus.isnogud.escape.de>	<20070925122244.15989.5@janus.isnogud.escape.de>	<20070925.222631.116063075.yoshfuji@linux-ipv6.org> <ygfir5yetfp.fsf@janus.isnogud.escape.de> <46F91F64.2050008@trash.net> <46F94B91.5020209@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-15?Q?YOSHIFUJI_Hideaki_/_=C8=A3=D1=C0?=
	<yoshfuji@linux-ipv6.org>, Urs Thuermann <urs@isnogud.escape.de>,
	netdev@vger.kernel.org, davem@davemloft.net, joe@perches.com,
	tglx@linutronix.de, oliver.hartkopp@volkswagen.de
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41116 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189AbXIYSCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 14:02:37 -0400
In-Reply-To: <46F94B91.5020209@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Hartkopp wrote:
>>>>I do think you need to allow people to select GPLv2 only.
>>>>      
>>>
> The Linux Kernel is currently under GPLv2 and we just wanted to follow
> Linus' mind and so we referenced the COPYING file which many other
> source does as well. Indeed it was a hard thing to make our code
> available under GPL (as creating and publishing open source software is
> really no a usual thing for the Volkswagen rights department). So i
> discussed with the rights department about several disclaimers inside
> the current Kernel (especially the stuff that has been signed off by
> companies like IBM, Motorola, etc.). In this process it turned out to be
> the best to license the code under "Dual BSD/GPL" as it grants more
> rights to the programmer (including ourselves) than a GPL only license.
> I assume this was the intention from IBM, Motorola and all the others
> also. Btw. inside the Kernel context it behaves exactly like GPL code
> (like all the other dual license code).
> 
> So i really can't see any problem here. If so there would have been a
> big discussion about the other "Dual BSD/GPL" code.


Yoshifuji's point was that the license seems to contradict itself,
it says you may choose GPL, but have to retain BSD. And that is
not about Dual BSD/GPL but about the specific wording.

/me runs and refrains from the discussion as promised :)
