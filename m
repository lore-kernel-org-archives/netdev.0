From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/33] ip: convert to net_device_ops for ioctl
Date: Wed, 19 Nov 2008 21:52:34 -0800 (PST)
Message-ID: <20081119.215234.219448936.davem@davemloft.net>
References: <20081117234207.854110282@vyatta.com>
	<20081117234355.629353591@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48702
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752841AbYKTFwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 00:52:34 -0500
In-Reply-To: <20081117234355.629353591@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 17 Nov 2008 15:42:17 -0800

> Convert to net_device_ops function table pointer for ioctl.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
