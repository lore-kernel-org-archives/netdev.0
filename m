From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: spread __net_init, __net_exit
Date: Sun, 17 Jan 2010 19:16:17 -0800 (PST)
Message-ID: <20100117.191617.123049160.davem@davemloft.net>
References: <20100117133532.GB6178@x200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48115
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754788Ab0ARDQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2010 22:16:07 -0500
In-Reply-To: <20100117133532.GB6178@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sun, 17 Jan 2010 15:35:32 +0200

> __net_init/__net_exit are apparently not going away, so use them
> to full extent.
> 
> In some cases __net_init was removed, because it was called from
> __net_exit code.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied to net-next-2.6

