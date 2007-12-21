From: David Miller <davem@davemloft.net>
Subject: Re: BNX2 warning
Date: Fri, 21 Dec 2007 15:05:12 -0800 (PST)
Message-ID: <20071221.150512.118852186.davem@davemloft.net>
References: <20071220.203935.30925934.davem@davemloft.net>
	<1198262055.28427.2.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42192
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754191AbXLUXFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 18:05:13 -0500
In-Reply-To: <1198262055.28427.2.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 21 Dec 2007 10:34:15 -0800

> [BNX2]: Fix compiler warning.
> 
> Change bnx2_init_napi() to void.
> 
> Warning was noted by DaveM.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks!
