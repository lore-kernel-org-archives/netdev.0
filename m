From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] bonding cleaning
Date: Mon, 17 Feb 2014 00:29:47 -0500 (EST)
Message-ID: <20140217.002947.1273623195685496622.davem@davemloft.net>
References: <cover.1392508410.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392508410.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sat, 15 Feb 2014 15:57:03 -0800

> Miscellaneous cleanups
> 
> Joe Perches (4):
>   bonding: Convert pr_warning to pr_warn, neatening
>   bonding: Neaten pr_<level>
>   bonding: Convert c99 comments
>   bonding: Convert memcpy(foo, bar, ETH_ALEN) to ether_addr_copy(foo, bar)

Series applied, thanks.
