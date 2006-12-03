From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rose_add_loopback_node: propagate -E
Date: Sat, 02 Dec 2006 22:17:59 -0800 (PST)
Message-ID: <20061202.221759.25475605.davem@davemloft.net>
References: <20061202213339.GB2714@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42161
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1424997AbWLCGSp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 01:18:45 -0500
To: adobriyan@gmail.com
In-Reply-To: <20061202213339.GB2714@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sun, 3 Dec 2006 00:33:39 +0300

> David Binderman's icc logs:
> net/rose/rose_route.c(399): remark #593: variable "err" was set but never used
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, thanks Alexey.
