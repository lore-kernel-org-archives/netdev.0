From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dsa: Use netdev_<level> instead of printk
Date: Tue, 11 Nov 2014 13:31:46 -0500 (EST)
Message-ID: <20141111.133146.953251668738222622.davem@davemloft.net>
References: <1415579566.23530.47.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	f.fainelli@gmail.com
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415579566.23530.47.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun, 09 Nov 2014 16:32:46 -0800

> Neaten and standardize the logging output.
> 
> Other miscellanea:
> 
> o Use pr_notice_once instead of a guard flag.
> o Convert existing pr_<level> uses too.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
