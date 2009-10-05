From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 21/21] drivers/net/tlan.h: Convert printk(KERN_DEBUG to
 pr_dbg(
Date: Mon, 05 Oct 2009 00:20:36 -0700 (PDT)
Message-ID: <20091005.002036.17911191.davem@davemloft.net>
References: <29c66ee0bae26a0c352b4605e3f1fcbe0612f3a5.1254701151.git.joe@perches.com>
	<20091005.001240.111554671.davem@davemloft.net>
	<1254726974.1799.315.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, chessman@tux.org,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758538AbZJEHUn@vger.kernel.org>
In-Reply-To: <1254726974.1799.315.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 05 Oct 2009 00:16:14 -0700

> On Mon, 2009-10-05 at 00:12 -0700, David Miller wrote:
>> From: Joe Perches <joe@perches.com>
>> Date: Sun,  4 Oct 2009 17:53:48 -0700
>> > Removed "TLAN: " prefix from debug printks, it's added by pr_fmt
>> > Signed-off-by: Joe Perches <joe@perches.com>
>> Applied to net-next-2.6
> 
> Patches 20 and 21 depend on patch 1, which introduces pr_dbg
> to kernel.h.  Compile failure otherwise.

Ok, I'll toss them then.

Someone else merge this stuff:

Acked-by: David S. Miller <davem@davemloft.net>
