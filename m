From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] netpoll: Convert printks to np_<level>
 and add pr_fmt
Date: Wed, 01 Feb 2012 14:22:08 -0500 (EST)
Message-ID: <20120201.142208.1925500569694245125.davem@davemloft.net>
References: <8a61df72a4eb6caaeaa8b5be644be227da61512b.1327888082.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8a61df72a4eb6caaeaa8b5be644be227da61512b.1327888082.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun, 29 Jan 2012 17:50:43 -0800

> Use a more current message logging style.
> Add pr_fmt to prefix dmesg output with "netpoll: "
> Add macros to print np->name.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
