From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 09/15] drivers/net/sis190.c: Use
 (pr|netdev|netif)_<level> macro helpers
Date: Thu, 18 Feb 2010 15:44:09 -0800 (PST)
Message-ID: <20100218.154409.154475074.davem@davemloft.net>
References: <cover.1266454575.git.joe@perches.com>
	<a9449fa4b0219cd2e0699f3afe4f8ca811b72843.1266454576.git.joe@perches.com>
	<1266472817.8446.258.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1266472817.8446.258.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 17 Feb 2010 22:00:17 -0800

> Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> Remove #define PFX
> Use pr_<level>
> Use netdev_<level>
> Use netif_<level> and netif_msg_<test>
> Remove local #define net_<test> macros
> Remove periods from formats
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
