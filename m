From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [RFC PATCH] netfilter: remove the duplicate tables
Date: Fri, 19 Nov 2010 21:03:27 +0800
Message-ID: <AANLkTinR4b_V1J7TDL6jXCmJNL8cHaWSbteoLWF60w_M@mail.gmail.com>
References: <1290091194-1590-1-git-send-email-xiaosuo@gmail.com>
 <1290095020.2781.203.camel@edumazet-laptop> <alpine.LNX.2.01.1011191210290.29394@obet.zrqbmnf.qr>
 <1290166180.3034.119.camel@edumazet-laptop> <AANLkTikF83kxggqyxoxw0m6L5km3zogPsiV7wVO1jbXy@mail.gmail.com>
 <alpine.LNX.2.01.1011191354160.20769@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37709 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754178Ab0KSNDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 08:03:49 -0500
In-Reply-To: <alpine.LNX.2.01.1011191354160.20769@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 19, 2010 at 8:57 PM, Jan Engelhardt <jengelh@medozas.de> wrote:
> There probably should be at most one copy per NUMA node. Maybe less,
> depending on what the benchmarks will say.
>
> I started on some patch to reduce the ruleset from #cpu to #numa_nodes,

It is a great idea! :)


-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
