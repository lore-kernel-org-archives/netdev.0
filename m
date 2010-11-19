From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [RFC PATCH] netfilter: remove the duplicate tables
Date: Fri, 19 Nov 2010 14:11:12 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1011191410420.20769@obet.zrqbmnf.qr>
References: <1290091194-1590-1-git-send-email-xiaosuo@gmail.com> <1290095020.2781.203.camel@edumazet-laptop> <alpine.LNX.2.01.1011191210290.29394@obet.zrqbmnf.qr> <1290166180.3034.119.camel@edumazet-laptop> <AANLkTikF83kxggqyxoxw0m6L5km3zogPsiV7wVO1jbXy@mail.gmail.com>
 <alpine.LNX.2.01.1011191354160.20769@obet.zrqbmnf.qr> <AANLkTinR4b_V1J7TDL6jXCmJNL8cHaWSbteoLWF60w_M@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinR4b_V1J7TDL6jXCmJNL8cHaWSbteoLWF60w_M@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 2010-11-19 14:03, Changli Gao wrote:

>On Fri, Nov 19, 2010 at 8:57 PM, Jan Engelhardt <jengelh@medozas.de> wrote:
>> There probably should be at most one copy per NUMA node. Maybe less,
>> depending on what the benchmarks will say.
>>
>> I started on some patch to reduce the ruleset from #cpu to #numa_nodes,
>
>It is a great idea! :)

Feel free to do it. (I don't have the patch anymore. It was just a few 
lines anyway.)
