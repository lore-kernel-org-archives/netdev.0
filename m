From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/25] netfilter updates from net-next (upcoming 3.6)
Date: Mon, 11 Jun 2012 13:08:40 -0700 (PDT)
Message-ID: <20120611.130840.1053126708259432739.davem@davemloft.net>
References: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Mon, 11 Jun 2012 16:43:36 +0200

> * Netns support for all our nf_conntrack sysctl tweaks, including global
>   timeout adjustment from Gao Feng.
> 
> * Add fail-open support to NFQUEUE, ie. don't drop packets if the kernel-space
>   nfqueue gets full, instead we allow packets to go through, from Krishna Kumar.
> 
> * Remove support for connlimit revision 0, as we already scheduled, from
>   Cong Wang.
> 
> * Improve load distribution in NFQUEUE if multi-queue is used from Florian
>   Westphal.
> 
> * Minor cleanups from Alban Crequy to use NFPROTO_* constants instead of
>   PF_* as we do in other parts of the Netfilter code.
> 
> You can pull these changes from:
> 
> git://1984.lsi.us.es/net-next master

Pulled, thanks Pablo!
