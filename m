From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Netfilter fixes for net
Date: Fri, 03 Mar 2017 20:41:37 -0800 (PST)
Message-ID: <20170303.204137.1405124737879829792.davem@davemloft.net>
References: <1488568945-4177-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1488568945-4177-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Fri,  3 Mar 2017 20:22:21 +0100

> The following patchset contains Netfilter fixes for your net tree,
> they are:
> 
> 1) Missing check for full sock in ip_route_me_harder(), from
>    Florian Westphal.
> 
> 2) Incorrect sip helper structure initilization that breaks it when
>    several ports are used, from Christophe Leroy.
> 
> 3) Fix incorrect assumption when looking up for matching with adjacent
>    intervals in the nft_set_rbtree.
> 
> 4) Fix broken netlink event error reporting in nf_tables that results
>    in misleading ESRCH errors propagated to userspace listeners.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Pulled, thanks a lot Pablo.
