From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/10] netfilter fixes for net-next
Date: Thu, 25 Apr 2013 00:54:18 -0400 (EDT)
Message-ID: <20130425.005418.2017316083264142873.davem@davemloft.net>
References: <1366849341-10466-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1366849341-10466-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 25 Apr 2013 02:22:11 +0200

> The following patchset contains fixes for recently applied
> Netfilter/IPVS updates to the net-next tree, most relevantly
> they are:
> 
> * Fix sparse warnings introduced in the RCU conversion, from
>   Julian Anastasov.
> 
> * Fix wrong endianness in the size field of IPVS sync messages,
>   from Simon Horman.
> 
> * Fix missing if checking in nf_xfrm_me_harder, from Dan Carpenter.
> 
> * Fix off by one access in the IPVS SCTP tracking code, again from
>   Dan Carpenter.

Pulled, thanks Pablo.
