From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/9][BNX2]: Support multiple MSIX IRQs.
Date: Thu, 20 Dec 2007 19:59:43 -0800 (PST)
Message-ID: <20071220.195943.251814410.davem@davemloft.net>
References: <1198182767.9163.32.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56289
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753884AbXLUD7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 22:59:44 -0500
In-Reply-To: <1198182767.9163.32.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 20 Dec 2007 12:32:47 -0800

> [BNX2]: Support multiple MSIX IRQs.
> 
> Change bnx2_napi struct into an array and add code to manage multiple
> IRQs.  MSIX hardware structures and new registers are also added.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
