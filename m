From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Netfilter/IPVS updates for your net tree (3.7)
Date: Thu, 18 Oct 2012 15:18:18 -0400 (EDT)
Message-ID: <20121018.151818.1882310621973081517.davem@davemloft.net>
References: <1350470334-5742-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1350470334-5742-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Wed, 17 Oct 2012 12:38:50 +0200

> The following patchset contains Netfilter/IPVS updates for your
> net tree, they are:
> 
> * Fix incorrect hooks for SNAT and DNAT (bug introduced in recent IPv6
>   NAT changes), from Elison Niven.
> 
> * Fix xt_TEE (got broken with recent rt_gateway semantic change),
>   from Eric Dumazet.
> 
> * Fix custom conntrack timeout policy attachment for IPv6, from myself.
> 
> * Always initialize ip_vs_timeout_user in case that TCP or UDP protocols
>   is disabled, from Arnd Bergmann.

Pulled, thanks Pablo.
