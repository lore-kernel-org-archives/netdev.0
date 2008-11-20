From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/33] bonding: convert to net_device_ops
Date: Wed, 19 Nov 2008 21:56:49 -0800 (PST)
Message-ID: <20081119.215649.37983456.davem@davemloft.net>
References: <20081117234207.854110282@vyatta.com>
	<20081117234355.801893533@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39132
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751473AbYKTF4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 00:56:49 -0500
In-Reply-To: <20081117234355.801893533@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 17 Nov 2008 15:42:19 -0800

> Convert to net_device_ops table. 
> Note: for some operations move error checking into generic networking
> layer (rather than looking at pointers in bonding).
> 
> A couple of gratituous style cleanups to get rid of extra {}
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
