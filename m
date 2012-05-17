From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: core: Use pr_<level>
Date: Thu, 17 May 2012 05:00:26 -0400 (EDT)
Message-ID: <20120517.050026.6264348104559960.davem@davemloft.net>
References: <1337234320.17726.26.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337234320.17726.26.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 16 May 2012 22:58:40 -0700

> Use the current logging style.
> 
> This enables use of dynamic debugging as well.
> 
> Convert printk(KERN_<LEVEL> to pr_<level>.
> Add pr_fmt. Remove embedded prefixes, use
> %s, __func__ instead.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
