From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 22/22] ne2k: convert to net_device_ops
Date: Fri, 21 Nov 2008 17:39:09 -0800 (PST)
Message-ID: <20081121.173909.179340455.davem@davemloft.net>
References: <20081121232138.343333942@vyatta.com>
	<20081121232240.762641910@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34385
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758044AbYKVBjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 20:39:10 -0500
In-Reply-To: <20081121232240.762641910@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 21 Nov 2008 15:22:00 -0800

> Convert driver to new net_device_ops. Compile tested only.
> This required some additional work to export common code ei_XXX.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
