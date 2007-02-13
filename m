From: David Miller <davem@davemloft.net>
Subject: Re: [TG3 2/8]: Use lower DMA watermark for 5703.
Date: Tue, 13 Feb 2007 12:19:22 -0800 (PST)
Message-ID: <20070213.121922.125898571.davem@davemloft.net>
References: <1171397641.18944.26.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41996
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750790AbXBMUTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 15:19:23 -0500
In-Reply-To: <1171397641.18944.26.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 13 Feb 2007 12:14:01 -0800

> [TG3]: Use lower DMA watermark for 5703.
> 
> Set DMA read watermark to 4 on 5703 in PCIX mode.  This is needed to
> prevent some tx timeouts.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
