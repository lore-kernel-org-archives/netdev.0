From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/19] netfilter updates for net-next (upcoming 3.3)
Date: Sun, 25 Dec 2011 03:12:43 -0500 (EST)
Message-ID: <20111225.031243.1507750002843759659.davem@davemloft.net>
References: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Sun, 25 Dec 2011 02:57:16 +0100

> The following patchset includes the Netfilter updates for net-next.
> It contains:
> 
> - New reverse path filter matches for xtables from Florian Westphal.
> 
> - Use of atomic64_t for the conntrack packet and bytes counters, instead
>   of using spinlock to protect counters updates from Eric Dumazet.
> 
> - One enhancement for the SH scheduler (IPVS) from Michael Maxim.
> 
> - Seven patches from Patrick McHardy to cleanup several aspects of the
>   existing NAT code.
> 
> - The rework of the user-space expectation support by myself.
> 
> - Several updates for ctnetlink by myself.
> 
> - The new nfacct infrastructure and the corresponding xtables match
>   by myself.
> 
> You can pull these changes from:
> 
> git://1984.lsi.us.es/net-next nf-next

Pulled, thanks a lot.
