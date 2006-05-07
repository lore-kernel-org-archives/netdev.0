From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] irda-usb: use NULL instead of 0
Date: Sat, 06 May 2006 18:34:32 -0700 (PDT)
Message-ID: <20060506.183432.36022730.davem@davemloft.net>
References: <20060501150807.b05fe450.rdunlap@xenotime.net>
	<200605020019.25382.IvDoorn@gmail.com>
	<20060501153134.811ac2d4.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ivdoorn@gmail.com, netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:53904
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751173AbWEGBeb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 May 2006 21:34:31 -0400
To: rdunlap@xenotime.net
In-Reply-To: <20060501153134.811ac2d4.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Randy.Dunlap" <rdunlap@xenotime.net>
Date: Mon, 1 May 2006 15:31:34 -0700

> Use NULL instead of 0 for a null pointer value (sparse warning):
> drivers/net/irda/irda-usb.c:1781:30: warning: Using plain integer as NULL pointer
> 
> Correct timeout argument to use milliseconds instead of jiffies.
> 
> Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>

Applied, thanks Randy.
