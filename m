From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 18/33] tun: convert to net_device_ops
Date: Wed, 19 Nov 2008 22:10:51 -0800 (PST)
Message-ID: <20081119.221051.192849254.davem@davemloft.net>
References: <20081117234207.854110282@vyatta.com>
	<20081117234356.327503270@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39458
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751043AbYKTGKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 01:10:51 -0500
In-Reply-To: <20081117234356.327503270@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 17 Nov 2008 15:42:25 -0800

> Convert the TUN/TAP tunnel driver to net_device_ops.
> Split the ops in two, and retain compatability.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
