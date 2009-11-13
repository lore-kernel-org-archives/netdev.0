From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Fri, 13 Nov 2009 08:18:32 +0100
Message-ID: <4AFD0848.6010708@trash.net>
References: <4AFA8911.7050204@gmail.com> <4AFBD911.6000900@gmail.com>	 <412e6f7f0911120148r48fa553bt610e013d96522a3d@mail.gmail.com>	 <4AFC25A7.10301@trash.net> <412e6f7f0911121732j106f96a2rb77f68098b7fd47e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43421 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753463AbZKMHS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 02:18:28 -0500
In-Reply-To: <412e6f7f0911121732j106f96a2rb77f68098b7fd47e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> On Thu, Nov 12, 2009 at 11:11 PM, Patrick McHardy <kaber@trash.net> wrote:
>> Changli Gao wrote:
>>> The corresponding iprout2 patch is attached.
>> Printing the value during dumps is missing from this patch.
>>
> 
> I doesn't know the rules about adding more dumps. Can I add it in the
> end of the corresponding line?
> 
> ifb0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN qlen 32 ntxqs 4

Yes, sounds fine.
