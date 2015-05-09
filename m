From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: macb: Handle the RXUBR interrupt on all devices
Date: Sat, 09 May 2015 16:04:54 -0400 (EDT)
Message-ID: <20150509.160454.1045911244389894144.davem@davemloft.net>
References: <1430856025-1066-1-git-send-email-nathan.sullivan@ni.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nathan.sullivan@ni.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45054 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751581AbbEIUEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 16:04:55 -0400
In-Reply-To: <1430856025-1066-1-git-send-email-nathan.sullivan@ni.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Sullivan <nathan.sullivan@ni.com>
Date: Tue, 5 May 2015 15:00:25 -0500

> The same hardware issue the at91 must work around applies to at least the
> Zynq ethernet, and possibly more devices.  The driver also needs to handle
> the RXUBR interrupt since it turns it on with MACB_RX_INT_FLAGS anyway.
> 
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>

Applied, thank you.
