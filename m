From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 5/16][BNX2]: Save PCI state during suspend.
Date: Thu, 03 May 2007 13:20:49 -0700 (PDT)
Message-ID: <20070503.132049.109627805.davem@davemloft.net>
References: <1178068303.4820.35.camel@dell>
	<1178177359.4909.69.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52980
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754077AbXECUUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 16:20:48 -0400
In-Reply-To: <1178177359.4909.69.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 03 May 2007 00:29:19 -0700

> [BNX2]: Save PCI state during suspend.
> 
> This is needed to save the MSI state which will be lost during
> suspend.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
