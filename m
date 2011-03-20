From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] netfilter: netfilter fixes
Date: Sun, 20 Mar 2011 13:42:57 -0700 (PDT)
Message-ID: <20110320.134257.71116215.davem@davemloft.net>
References: <1300635148-22648-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300635148-22648-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: kaber@trash.net
Date: Sun, 20 Mar 2011 16:32:24 +0100

> the following patches fix a couple of netfilter bugs:
> 
> - a bug in ipset which caused the hash:port set types to silently
>   ignore address ranges when non-TCP/UDP entries were added, from
>   Jozsef
> 
> - a missing check for set type revision in ipset, from Jozsef
> 
> - a fix for iptables reentrancy, from Eric
> 
> - a fix for a buffer overflow in the ipt_CLUSTERIP proc handler,
>   from Vasiliy Kulikov
> 
> Please apply or pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Pulled, thanks a lot Patrick.
