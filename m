From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/16] ethernet: Convert dev_printk(KERN_<LEVEL> to
 dev_<level>(
Date: Fri, 02 Nov 2012 22:00:33 -0400 (EDT)
Message-ID: <20121102.220033.278425350670801966.davem@davemloft.net>
References: <cover.1351411047.git.joe@perches.com>
	<78c3d489101b08588cb067181171eb070bdac756.1351411047.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <78c3d489101b08588cb067181171eb070bdac756.1351411047.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun, 28 Oct 2012 01:05:48 -0700

> dev_<level> calls take less code than dev_printk(KERN_<LEVEL>
> and reducing object size is good.
> Coalesce formats for easier grep.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

I forgot the other day so indicate that I applied this to
net-next, thanks.
