From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] Netfilter updates for net-next
Date: Fri, 19 Apr 2013 17:56:11 -0400 (EDT)
Message-ID: <20130419.175611.494085952352187311.davem@davemloft.net>
References: <1366334638-5113-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1366334638-5113-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Fri, 19 Apr 2013 03:23:52 +0200

> The following patchset contains a small batch of Netfilter
> updates for your net-next tree, they are:
> 
> * Three patches that provide more accurate error reporting to
>   user-space, instead of -EPERM, in IPv4/IPv6 netfilter re-routing
>   code and NAT, from Patrick McHardy.
> 
> * Update copyright statements in Netfilter filters of
>   Patrick McHardy, from himself.
> 
> * Add Kconfig dependency on the raw/mangle tables to the
>   rpfilter, from Florian Westphal.
 ...
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

Pulled, thanks Pablo.
