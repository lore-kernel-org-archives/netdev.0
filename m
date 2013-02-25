From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] usbnet: smsc95xx: fix smsc95xx_suspend
Date: Mon, 25 Feb 2013 15:50:08 -0500 (EST)
Message-ID: <20130225.155008.2113562107665771295.davem@davemloft.net>
References: <1361538305-28418-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, oneukum@suse.de,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: ming.lei@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56091 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759560Ab3BYUuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 15:50:10 -0500
In-Reply-To: <1361538305-28418-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ming Lei <ming.lei@canonical.com>
Date: Fri, 22 Feb 2013 21:05:02 +0800

> The 1st two patches fix smsc95xx_suspend, and the 1st one should
> be backported to 3.8.
> 
> The last one is to rename the misleading FEATURE_AUTOSUSPEND.

All applied, thanks.
