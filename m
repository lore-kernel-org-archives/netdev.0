From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] dev_<level> and dynamic_debug cleanups
Date: Thu, 30 Aug 2012 13:16:59 -0400 (EDT)
Message-ID: <20120830.131659.1142504331858011461.davem@davemloft.net>
References: <cover.1345978012.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org, jbaron@redhat.com,
	jim.cromie@gmail.com, kay@vrfy.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1345978012.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun, 26 Aug 2012 04:25:25 -0700

> The recent commit to fix dynamic_debug was a bit unclean.
> Neaten the style for dynamic_debug.
> Reduce the stack use of message logging that uses netdev_printk
> Add utility functions dev_printk_emit and dev_vprintk_emit for /dev/kmsg.

I think these should go through the generic device tree, feel free to
add my:

Acked-by: David S. Miller <davem@davemloft.net>
