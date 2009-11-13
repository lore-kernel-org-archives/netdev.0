From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Fri, 13 Nov 2009 09:32:36 +0800
Message-ID: <412e6f7f0911121732j106f96a2rb77f68098b7fd47e@mail.gmail.com>
References: <4AFA8911.7050204@gmail.com> <4AFBD911.6000900@gmail.com>
	 <412e6f7f0911120148r48fa553bt610e013d96522a3d@mail.gmail.com>
	 <4AFC25A7.10301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:42500 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754067AbZKMBcb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 20:32:31 -0500
Received: by pzk1 with SMTP id 1so953745pzk.33
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2009 17:32:37 -0800 (PST)
In-Reply-To: <4AFC25A7.10301@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 12, 2009 at 11:11 PM, Patrick McHardy <kaber@trash.net> wro=
te:
> Changli Gao wrote:
>> The corresponding iprout2 patch is attached.
>
> Printing the value during dumps is missing from this patch.
>

I doesn't know the rules about adding more dumps. Can I add it in the
end of the corresponding line?

ifb0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN qlen 32 ntxqs 4

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
