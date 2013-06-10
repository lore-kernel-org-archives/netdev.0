From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] netfilter fixes for 3.10-rc5
Date: Mon, 10 Jun 2013 13:32:00 -0700 (PDT)
Message-ID: <20130610.133200.288719279625686046.davem@davemloft.net>
References: <1370880461-4265-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1370880461-4265-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 10 Jun 2013 18:07:36 +0200

> The following patchset contains four fixes for Netfilter and one fix
> for IPVS, they are:
> 
> * Fix data leak to user-space via getsockopt IP_VS_SO_GET_DESTS, from
>   Dan Carpenter.
> 
> * Fix xt_TCPMSS if no TCP MSS is specified in syn packets, to avoid the
>   violation of RFC879, from Phil Oester.
> 
> * Fix incomplete dump of objects via nfnetlink_acct and nfnetlink_cttimeout,
>   from myself.
> 
> * Fix missing HW protocol in packets passed to user-space via NFQUEUE,
>   from myself.
> 
> You can pull these changes from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Pulled, thanks Pablo!
