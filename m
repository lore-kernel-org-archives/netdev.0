From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0 / 5] move the common CDC parser
Date: Fri, 15 Jul 2016 11:51:47 -0700 (PDT)
Message-ID: <20160715.115147.1896139966807241395.davem@davemloft.net>
References: <1468503694-9482-1-git-send-email-oneukum@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	gregKH@linuxfoundation.org, bjorn@mork.no
To: oneukum@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51440 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbcGOSvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 14:51:49 -0400
In-Reply-To: <1468503694-9482-1-git-send-email-oneukum@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.com>
Date: Thu, 14 Jul 2016 15:41:29 +0200

> Experience has shown that making all CDC drivers depend on usbnet
> is not practical, because some of them are not network drivers.
> So this patch moves the common parser from usbnet into the messages
> helpers of usbcore.
> The rest of the series applies it to the non-network CDC drivers.
> 
> I hope it can go through Greg's tree although it touches usbnet.

I'm fine with Greg taking this series, sure.
