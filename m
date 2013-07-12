From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/usb: add relative mii functions for r815x
Date: Thu, 11 Jul 2013 17:11:42 -0700 (PDT)
Message-ID: <20130711.171142.827990641403291865.davem@davemloft.net>
References: <1373251281-2402-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, oliver@neukum.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, nic_swsd@realtek.com
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33700 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756349Ab3GLALn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 20:11:43 -0400
In-Reply-To: <1373251281-2402-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>
Date: Mon, 8 Jul 2013 10:41:21 +0800

> Base on cdc_ether, add the mii functions for RTL8152 and RTL8153.
> The RTL8152 and RTL8153 support ECM mode which use the driver of
> cdc_ether. Add the mii functions. Then, the basic PHY access is
> possible.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

This looks like a pretty straightforward addition of support for
new chips, so applied, thanks.
