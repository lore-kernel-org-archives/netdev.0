From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] netfilter updates for net-next (batch 3)
Date: Wed, 16 May 2012 20:00:29 -0400 (EDT)
Message-ID: <20120516.200029.92801957434659335.davem@davemloft.net>
References: <1337209604-3412-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1337209604-3412-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Thu, 17 May 2012 01:06:37 +0200

> The following patchset contains small updates for net-next, more relevantly:
> 
> * One fix for potential NULL dereference in xt_HMARK by Dan Carpenter.
> 
> * Conversion to use _ALL macro in xt_hashlimit as you suggested by
>   Florian Westphal.
> 
> * One fix for timeout overflow from Jozsef Kadlecsik.
> 
> * Replace usage of modulus for hash calculation in xt_HMARK as you suggested
>   from myself.
> 
> You can pull these changes from:
> 
> git://1984.lsi.us.es/net-next master

Pulled, thanks a lot!
