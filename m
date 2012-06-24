From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] netfilter updates for net-next (upcoming 3.6),
 batch 4
Date: Sat, 23 Jun 2012 17:14:39 -0700 (PDT)
Message-ID: <20120623.171439.269257012571243684.davem@davemloft.net>
References: <1340495609-26250-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1340495609-26250-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Sun, 24 Jun 2012 01:53:25 +0200

> From: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> Hi David,
> 
> The following four patches provide Netfilter fixes for the cthelper
> infrastructure that was recently merged mainstream, they are:
> 
> * two fixes for compilation breakage with two different configurations:
> 
>   - CONFIG_NF_NAT=m and CONFIG_NF_CT_NETLINK=y
>   - NF_CONNTRACK_EVENTS=n and CONFIG_NETFILTER_NETLINK_QUEUE_CT=y
> 
> * two fixes for sparse warnings.
> 
> You can pull this changes from:
> 
> git://1984.lsi.us.es/nf-next master

Pulled, thanks Pablo.
