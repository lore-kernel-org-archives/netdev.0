From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] netfilter updates for net-next (2nd round)
Date: Wed, 28 Dec 2011 13:37:43 -0500 (EST)
Message-ID: <20111228.133743.432485107673446683.davem@davemloft.net>
References: <1325079573-6120-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	jengelh@medozas.de, kaber@trash.net
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1325079573-6120-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Wed, 28 Dec 2011 14:39:28 +0100

> From: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> Hi Dave,
> 
> These are a couple of late updates from Jan Engelhardt, who has been
> kind enough to recover the unmerged ECN support for IPv6. The IPv6
> ECN support is original work from Patrick McHardy.
> 
> This includes one patch to obsolete the /proc/net/[nf|ip]_conntrack
> outputs in favour of conntrack(8). Basically, it adds some compilation
> time option to disable it. Later on, we can schedule it for removal.
> 
> You can pull this changes from:
> 
> git://1984.lsi.us.es/net-next nf-next

Pulled, thanks a lot.
