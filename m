From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/25] Netfilter updates for net-next
Date: Mon, 03 Sep 2012 20:39:55 -0400 (EDT)
Message-ID: <20120903.203955.1132524974832821579.davem@davemloft.net>
References: <1346716452-3080-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1346716452-3080-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Tue,  4 Sep 2012 01:53:47 +0200

> The following patchset contains updates for your net-next tree, the most
> relevant thing here is the new IPv6 NAT support from Patrick McHardy.
> More specifically, they are:
> 
> * Several patches to prepare IPv6 NAT support, including one to improve
>   IPv6 fragmentation handling for Netfilter and IPVS from Patrick McHardy
>   and Jesper Dangaard respectively.
> 
> * IPv6 NAT support for source/destination NAT, masquerading, redirection
>   and network mapping, again from Patrick.
> 
> * A new target that allows stateless Network Prefix Translation (NPT)
>   for IPv6, also from Patrick.
> 
> * Changes in existing helpers to support IPv6 NAT, mostly and Patrick and
>   a couple from myself.
> 
> * Removal of xt_NOTRACK that has now been superseded by the CT target, from
>   Cong Wang.
> 
> * Minor cleanups from Jan Beulich, Michael Wang and myself.
> 
> You can pull these changes from:
> 
> git://1984.lsi.us.es/nf-next master

Pulled and pushed out to net-next, thanks!
