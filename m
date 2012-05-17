From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] lapb: Neaten debugging
Date: Thu, 17 May 2012 18:45:40 -0400 (EDT)
Message-ID: <20120517.184540.2184273930158423710.davem@davemloft.net>
References: <1337286349.17726.58.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-x25@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337286349.17726.58.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu, 17 May 2012 13:25:49 -0700

> Enable dynamic debugging and remove a bunch of #ifdef/#endifs.
> 
> Add a lapb_dbg(level, fmt, ...) macro and replace the
> printk(KERN_DEBUG uses.
> Add pr_fmt and remove embedded prefixes.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
