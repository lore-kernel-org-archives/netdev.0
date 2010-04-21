From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: small cleanup of lib8390
Date: Wed, 21 Apr 2010 16:23:45 -0700 (PDT)
Message-ID: <20100421.162345.58444807.davem@davemloft.net>
References: <201004151751.23899.knikanth@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: p_gortmaker@yahoo.com, netdev@vger.kernel.org,
	viro@ftp.linux.org.uk, jeff@garzik.org
To: knikanth@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38926
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754954Ab0DUXXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 19:23:40 -0400
In-Reply-To: <201004151751.23899.knikanth@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikanth Karthikesan <knikanth@suse.de>
Date: Thu, 15 Apr 2010 17:51:23 +0530

> Remove the always true #if 1. Also the unecessary re-test of ei_local->irqlock
> and the unreachable printk format string.
> 
> Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>

Applied to net-next-2.6, thanks.
