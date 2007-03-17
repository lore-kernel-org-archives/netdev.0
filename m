From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] [net-2.6.22] IrDA: SMC SuperIO Chip LPC47N227 not
 identified properly
Date: Fri, 16 Mar 2007 20:39:43 -0700 (PDT)
Message-ID: <20070316.203943.131105538.davem@davemloft.net>
References: <20070317015937.GD3429@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	peter.kovar@gmail.com, khali@linux-fr.org,
	akpm@linux-foundation.org
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59277
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933177AbXCQDjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 23:39:46 -0400
In-Reply-To: <20070317015937.GD3429@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel@sortiz.org>
Date: Sat, 17 Mar 2007 03:59:37 +0200

> SMC SuperIO Chip LPC47N227 used for IrDA is not detected because its device
> identification byte can be 0x7A instead of 0x5A.
> 
> Patch from Peter Kovar <peter.kovar@gmail.com>
> Cc: Jean Delvare <khali@linux-fr.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Applied, thanks.
