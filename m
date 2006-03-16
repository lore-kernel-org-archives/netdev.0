From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: Cleanup of net/ipv6/reassambly.c
Date: Thu, 16 Mar 2006 00:14:59 -0800 (PST)
Message-ID: <20060316.001459.104988434.davem@davemloft.net>
References: <200603120049.49294.ioe-lkml@rameria.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932401AbWCPIPU@vger.kernel.org>
To: ioe-lkml@rameria.de
In-Reply-To: <200603120049.49294.ioe-lkml@rameria.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Oeser <ioe-lkml@rameria.de>
Date: Sun, 12 Mar 2006 00:49:48 +0100

> Two minor cleanups:
> 
> 1. Using kzalloc() in fraq_alloc_queue() 
>    saves the memset() in ipv6_frag_create().
> 
> 2. Invert sense of if-statements to streamline code.
>    Inverts the comment, too.
> 
> Signed-off-by: Ingo Oeser <ioe-lkml@rameria.de>

This patch looks great, applied.

Thanks a lot Ingo.
