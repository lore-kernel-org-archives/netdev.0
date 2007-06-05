From: David Miller <davem@davemloft.net>
Subject: Re: [3/5][BNX2]: Enable DMA on 5709.
Date: Mon, 04 Jun 2007 21:23:16 -0700 (PDT)
Message-ID: <20070604.212316.47310209.davem@davemloft.net>
References: <1181001648.5275.14.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37152
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754745AbXFEEXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 00:23:02 -0400
In-Reply-To: <1181001648.5275.14.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 04 Jun 2007 17:00:48 -0700

> [BNX2]: Enable DMA on 5709.
> 
> Add missing code to enable DMA on 5709 A1.  The bit is a no-op on
> A0 and therefore can be set on all 5709 chips.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
