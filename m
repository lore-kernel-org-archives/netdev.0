From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 3/16][BNX2]: Add 40-bit DMA workaround for 5708.
Date: Thu, 03 May 2007 13:19:57 -0700 (PDT)
Message-ID: <20070503.131957.62346614.davem@davemloft.net>
References: <1178068303.4820.35.camel@dell>
	<1178177330.4909.67.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52975
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754327AbXECUT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 16:19:56 -0400
In-Reply-To: <1178177330.4909.67.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 03 May 2007 00:28:50 -0700

> [BNX2]: Add 40-bit DMA workaround for 5708.
> 
> The internal PCIE-to-PCIX bridge of the 5708 has the same 40-bit DMA
> limitation as some of the tg3 chips.  Set dma_mask and persistent DMA
> mask to 40-bit to workaround.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
