From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Nearly complete kzalloc cleanup for net/ipv6
Date: Thu, 16 Mar 2006 00:17:15 -0800 (PST)
Message-ID: <20060316.001715.87364289.davem@davemloft.net>
References: <200603112136.43553.ioe-lkml@rameria.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750708AbWCPIRk@vger.kernel.org>
To: ioe-lkml@rameria.de
In-Reply-To: <200603112136.43553.ioe-lkml@rameria.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Oeser <ioe-lkml@rameria.de>
Date: Sat, 11 Mar 2006 21:36:42 +0100

> Stupidly use kzalloc() instead of kmalloc()/memset() 
> everywhere where this is possible in net/ipv6/*.c . 
> 
> Signed-off-by: Ingo Oeser <ioe-lkml@rameria.de>

This patch also looks fine.

Applied, thanks Ingo.
