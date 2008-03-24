From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] include/linux/icmpv6.h - remove duplicate include
Date: Sun, 23 Mar 2008 22:18:15 -0700 (PDT)
Message-ID: <20080323.221815.84933913.davem@davemloft.net>
References: <1205106928.656.102.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752762AbYCXFS7@vger.kernel.org>
In-Reply-To: <1205106928.656.102.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun, 09 Mar 2008 16:55:28 -0700

> Remove duplicate #include <linux/skbuff.h>
> Combine #ifdef __KERNEL__ blocks
> Neaten function prototypes
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Does not apply to net-2.6.26, dropped.
