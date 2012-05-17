From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pktgen: Use pr_debug
Date: Thu, 17 May 2012 05:00:15 -0400 (EDT)
Message-ID: <20120517.050015.719363234800027550.davem@davemloft.net>
References: <1337226641.17726.8.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337226641.17726.8.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 16 May 2012 20:50:41 -0700

> Convert printk(KERN_DEBUG to pr_debug which can
> enable dynamic debugging.
> 
> Remove embedded prefixes from the conversions as
> pr_fmt adds them.
> 
> Align arguments.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
