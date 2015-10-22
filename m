From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Netfilter fixes for net
Date: Wed, 21 Oct 2015 19:27:18 -0700 (PDT)
Message-ID: <20151021.192718.591664957813117408.davem@davemloft.net>
References: <1445278975-2412-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1445278975-2412-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 19 Oct 2015 20:22:51 +0200

> The following patchset contains four Netfilter fixes for net, they are:
> 
> 1) Fix Kconfig dependencies of new nf_dup_ipv4 and nf_dup_ipv6.
> 
> 2) Remove bogus test nh_scope in IPv4 rpfilter match that is breaking
>    --accept-local, from Xin Long.
> 
> 3) Wait for RCU grace period after dropping the pending packets in the
>    nfqueue, from Florian Westphal.
> 
> 4) Fix sleeping allocation while holding spin_lock_bh, from Nikolay Borisov.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Pulled, thanks a lot Pablo.
