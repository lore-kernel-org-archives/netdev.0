From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Netfilter/IPVS updates for net-next
Date: Fri, 30 May 2014 17:55:10 -0700 (PDT)
Message-ID: <20140530.175510.1647698160889534807.davem@davemloft.net>
References: <1401378900-12436-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1401378900-12436-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 29 May 2014 17:54:57 +0200

> This small patchset contains three accumulated Netfilter/IPVS updates,
> they are:
> 
> 1) Refactorize common NAT code by encapsulating it into a helper
>    function, similarly to what we do in other conntrack extensions,
>    from Florian Westphal.
> 
> 2) A minor format string mismatch fix for IPVS, from Masanari Iida.
> 
> 3) Add quota support to the netfilter accounting infrastructure, now
>    you can add quotas to accounting objects via the nfnetlink interface
>    and use them from iptables. You can also listen to quota
>    notifications from userspace. This enhancement from Mathieu Poirier.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Pulled into net-next, thanks Pablo!
