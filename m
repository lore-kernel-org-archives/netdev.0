From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/usb: Add Samsung Kalmia driver for Samsung GT-B3730
Date: Thu, 16 Jun 2011 22:01:12 -0400 (EDT)
Message-ID: <20110616.220112.882657314456163072.davem@davemloft.net>
References: <20110611.162942.1706711069327005315.davem@davemloft.net>
	<1307882102-31659-1-git-send-email-marius@kotsbak.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	marius@kotsbak.com
To: marius.kotsbak@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57975 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757967Ab1FQCBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 22:01:16 -0400
In-Reply-To: <1307882102-31659-1-git-send-email-marius@kotsbak.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Marius B. Kotsbak" <marius.kotsbak@gmail.com>
Date: Sun, 12 Jun 2011 14:35:02 +0200

> Introducing driver for the network port of Samsung Kalmia based USB LTE modems.
> It has also an ACM interface that previous patches associates with the "option"
> module. To access those interfaces, the modem must first be switched from modem
> mode using a tool like usb_modeswitch.
> 
> As the proprietary protocol has been discovered by watching the MS Windows driver
> behavior, there might be errors in the protocol handling, but stable and fast
> connection has been established for hours with Norwegian operator NetCom that
> distributes this modem with their LTE/4G subscription.
> 
> More and updated information about how to use this driver is available here:
> 
> http://www.draisberghof.de/usb_modeswitch/bb/viewtopic.php?t=465
> https://github.com/mkotsbak/Samsung-GT-B3730-linux-driver
> 
> Signed-off-by: Marius B. Kotsbak <marius@kotsbak.com>

Applied, thanks.
