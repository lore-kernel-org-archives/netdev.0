From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH] igb: use dev_printk instead of printk
Date: Thu, 20 Nov 2008 00:48:39 -0800 (PST)
Message-ID: <20081120.004839.80707116.davem@davemloft.net>
References: <20081118020635.10966.83143.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, bjorn.helgaas@hp.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52495
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753897AbYKTIsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 03:48:39 -0500
In-Reply-To: <20081118020635.10966.83143.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 17 Nov 2008 18:06:35 -0800

> From: Bjorn Helgaas <bjorn.helgaas@hp.com>
> 
> Use dev_printk() instead of printk() to give a little more context
> and use consistent format.
> 
> Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Already applied.
