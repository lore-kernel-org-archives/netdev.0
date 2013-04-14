From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] freescale: Update logging style
Date: Sun, 14 Apr 2013 15:43:58 -0400 (EDT)
Message-ID: <20130414.154358.755597670486116198.davem@davemloft.net>
References: <cover.1365915548.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, festevam@gmail.com,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1365915548.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sat, 13 Apr 2013 22:03:16 -0700

> Convert various printk logging styles to current styles.
> 
> Uncompiled, untested.
> 
> Joe Perches (3):
>   fec: Convert printks to netdev_<level>
>   gianfar: Use netdev_<level> when possible
>   ucc_geth: Convert ugeth_<level> to pr_<level>

All applied.
