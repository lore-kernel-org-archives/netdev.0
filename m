From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] netfilter: netfilter fixes for 2.6.38
Date: Sat, 19 Feb 2011 19:01:28 -0800 (PST)
Message-ID: <20110219.190128.71096194.davem@davemloft.net>
References: <1298130065-14205-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1298130065-14205-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: kaber@trash.net
Date: Sat, 19 Feb 2011 16:41:03 +0100

> the following patches for two netfilter bugs:
> 
> - an oops in nfnetlink_log in combination with TPROXY when a socket
>   in TIME-WAIT state is assigned to skb->sk, patch from Florian Westphal
> 
> - incorrect printing of the MAC header in the ip6t_LOG target,
>   from Joerg Marx
> 
> Please apply or pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Pulled, thanks Patrick.
