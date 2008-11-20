From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 30/33] tg3: convert to net_device_ops
Date: Wed, 19 Nov 2008 22:25:51 -0800 (PST)
Message-ID: <20081119.222551.111639658.davem@davemloft.net>
References: <20081117234207.854110282@vyatta.com>
	<20081117234357.345529638@vyatta.com>
	<20081117173706.31960184@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37212
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753592AbYKTGZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 01:25:51 -0500
In-Reply-To: <20081117173706.31960184@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 17 Nov 2008 17:37:06 -0800

> Convert this driver to network device ops.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> Handle non-vlan build.

Applied.
