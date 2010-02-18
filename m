From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 13/15] drivers/net/tg3.c: Use
 (pr|netdev)_<level> macro helpers
Date: Thu, 18 Feb 2010 15:44:02 -0800 (PST)
Message-ID: <20100218.154402.202540963.davem@davemloft.net>
References: <cover.1266454575.git.joe@perches.com>
	<89936828c4a4c914b849cf8c96985d62fb612e55.1266454576.git.joe@perches.com>
	<1266471859.8446.256.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1266471859.8446.256.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 17 Feb 2010 21:44:19 -0800

> Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> Remove #define PFX
> Use pr_<level>
> Use netdev_<level>
> Remove periods from most formats
> Coalesce long formats
> Use printk_once
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
