From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: remove certain HAVE_ macros
Date: Sat, 23 Jan 2010 01:21:42 -0800 (PST)
Message-ID: <20100123.012142.01762448.davem@davemloft.net>
References: <20100122201310.GA22342@x200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38055
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751487Ab0AWJVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 04:21:31 -0500
In-Reply-To: <20100122201310.GA22342@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 22 Jan 2010 22:13:10 +0200

> After netdev_ops compat code HAVE_* macros aren't needed, in fact
> they _will_ result in compile breakage for out of tree drivers.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, thanks a lot for doing this.
