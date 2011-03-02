From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] netfilter: netfilter fixes for 2.6.38
Date: Wed, 02 Mar 2011 11:29:41 -0800 (PST)
Message-ID: <20110302.112941.193724935.davem@davemloft.net>
References: <1299066981-14058-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1299066981-14058-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: kaber@trash.net
Date: Wed,  2 Mar 2011 12:56:19 +0100

> the following patches fix two IPVS/netfilter bugs:
> 
> - incorrect locking in __ip_vs_update_dest(), from Julian
> 
> - a potential oops when binding or unbinding an invalid address family
>   through nfnetlink_log, from Jan
> 
> Please apply or pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Pulled, thanks a lot Patrick.
