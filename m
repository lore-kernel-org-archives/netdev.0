From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Netfilter fixes for net-next
Date: Fri, 10 Oct 2014 15:01:28 -0400 (EDT)
Message-ID: <20141010.150128.999718046890657580.davem@davemloft.net>
References: <1412879261-25045-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1412879261-25045-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu,  9 Oct 2014 20:27:39 +0200

> This batch contains two fixes for what you have in your net-next,
> they are:
> 
> 1) Remove nf_send_reset6() from header file. This function now resides
>    in the nf_reject_ipv6 module. Reported by Eric Dumazet.
> 
> 2) Fix wrong NFT_REJECT_ICMPX_MAX definition and adjust code to fix
>    errors reported by Dan Carpenter's static analysis tools.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Pulled, thanks Pablo.
