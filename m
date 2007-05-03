From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 14/16][BNX2]: Add 1-shot MSI handler for 5709.
Date: Thu, 03 May 2007 13:24:58 -0700 (PDT)
Message-ID: <20070503.132458.89084752.davem@davemloft.net>
References: <1178068303.4820.35.camel@dell>
	<1178177498.4909.77.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42736
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031260AbXECUY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 16:24:57 -0400
In-Reply-To: <1178177498.4909.77.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 03 May 2007 00:31:38 -0700

> [BNX2]: Add 1-shot MSI handler for 5709.
> 
> The 5709 supports the one-shot MSI handler similar to some of the tg3
> chips.  In this mode, the MSI disables itself automatically until it
> is re-enabled at the end of NAPI poll.
> 
> Put the request_irq/free_irq logic in common procedures.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
