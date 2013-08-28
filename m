From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] netfilter updates for net-next
Date: Tue, 27 Aug 2013 22:07:44 -0400 (EDT)
Message-ID: <20130827.220744.1821388377674741024.davem@davemloft.net>
References: <1377644018-15685-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1377644018-15685-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Wed, 28 Aug 2013 00:53:30 +0200

> The following patchset contains Netfilter updates for your net-next tree,
> they are:
> 
> * The new SYNPROXY target for iptables, including IPv4 and IPv6 support,
>   from Patrick McHardy.
> 
> * nf_defrag_ipv6.o should be only linked to nf_defrag_ipv6.ko, from
>   Nathan Hintz.
> 
> * Fix an old bug in REJECT, which replies with wrong MAC source address
>   from the bridge, by Phil Oester.
> 
> * Fix uninitialized helper variable in the expectation support over
>   nfnetlink_queue, from Florian Westphal.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

Pulled, thanks Pablo.
