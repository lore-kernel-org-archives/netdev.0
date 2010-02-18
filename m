From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/15] drivers/net: Use
 (pr|netdev|netif)_<level> macros
Date: Wed, 17 Feb 2010 17:46:15 -0800 (PST)
Message-ID: <20100217.174615.133415843.davem@davemloft.net>
References: <cover.1266454575.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zambrano@broadcom.com, mchan@broadcom.com,
	eilong@broadcom.com, romieu@fr.zoreil.com,
	shemminger@linux-foundation.org, mcarlson@broadcom.com,
	dave@thedillows.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1266454575.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 17 Feb 2010 17:01:47 -0800

> Use the newly added netdev_<level> and netif_<level> logging macros
> in some of the drivers.
> 
> Adds some message logging consistency.
> 
> pci-skeleton had a checkpatch style cleaning as well.

The sis190.c and tg3.c changes didn't apply due to other
recent commits into the net-next-2.6 tree

I applied all of the others.

Thanks.
