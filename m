From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Netfilter fixes for net
Date: Wed, 13 Apr 2016 21:51:04 -0400 (EDT)
Message-ID: <20160413.215104.1460845070621381015.davem@davemloft.net>
References: <1460588094-3933-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1460588094-3933-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 14 Apr 2016 00:54:51 +0200

> The following patchset contains Netfilter fixes for your net tree. More
> specifically, they are:
> 
> 1) Fix missing filter table per-netns registration in arptables, from
>    Florian Westphal.
> 
> 2) Resolve out of bound access when parsing TCP options in
>    nf_conntrack_tcp, patch from Jozsef Kadlecsik.
> 
> 3) Prefer NFPROTO_BRIDGE extensions over NFPROTO_UNSPEC in ebtables,
>    this resolves conflict between xt_limit and ebt_limit, from Phil Sutter.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Pulled, thanks Pablo.
