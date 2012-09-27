From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc75xx: fix resume after device reset
Date: Thu, 27 Sep 2012 18:00:12 -0400 (EDT)
Message-ID: <20120927.180012.1412086025696296605.davem@davemloft.net>
References: <1348497779-10042-1-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steve.glendinning@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58639 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754140Ab2I0WAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 18:00:13 -0400
In-Reply-To: <1348497779-10042-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@shawell.net>
Date: Mon, 24 Sep 2012 15:42:59 +0100

> On some systems this device fails to properly resume after suspend,
> this patch fixes it by running the usbnet_resume handler.
> 
> I suspect this also fixes this bug:
> 
> http://code.google.com/p/chromium-os/issues/detail?id=31871

Applied, thanks.
