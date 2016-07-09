From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: remove the setting of LAN_WAKE_EN
Date: Fri, 08 Jul 2016 23:48:05 -0400 (EDT)
Message-ID: <20160708.234805.977885446725000684.davem@davemloft.net>
References: <1394712342-15778-208-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57930 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932844AbcGIDsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 23:48:06 -0400
In-Reply-To: <1394712342-15778-208-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>
Date: Wed, 6 Jul 2016 17:03:29 +0800

> The LAN_WAKE_EN is not used to determine if the device could support
> WOL. It is used to sigal a GPIO pin when a WOL event occurs. The WOL
> still works even though it is disabled.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied.
