From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 21/21] drivers/net/tlan.h: Convert printk(KERN_DEBUG to
 pr_dbg(
Date: Mon, 05 Oct 2009 00:12:40 -0700 (PDT)
Message-ID: <20091005.001240.111554671.davem@davemloft.net>
References: <cover.1254701151.git.joe@perches.com>
	<cover.1254701151.git.joe@perches.com>
	<29c66ee0bae26a0c352b4605e3f1fcbe0612f3a5.1254701151.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, chessman@tux.org,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758454AbZJEHMs@vger.kernel.org>
In-Reply-To: <29c66ee0bae26a0c352b4605e3f1fcbe0612f3a5.1254701151.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun,  4 Oct 2009 17:53:48 -0700

> Removed "TLAN: " prefix from debug printks, it's added by pr_fmt
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied to net-next-2.6
