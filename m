From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: add HAVE_NET_DEVICE_OPS
Date: Tue, 25 Nov 2008 00:20:57 -0800 (PST)
Message-ID: <20081125.002057.35351129.davem@davemloft.net>
References: <20081124103947.32307e7b@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33373
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751681AbYKYIU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 03:20:58 -0500
In-Reply-To: <20081124103947.32307e7b@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 24 Nov 2008 10:39:47 -0800

> As a concession to vendors who have to deal with one source for different
> kernel versions, add a HAVE_NET_DEVICE_OPS so they don't end up hard
> coding ifdef against kernel version.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Makes sense.

Applied, thanks Stephen.
