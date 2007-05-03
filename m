From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 12/16][BNX2]: Add indirect spinlock.
Date: Thu, 03 May 2007 13:24:11 -0700 (PDT)
Message-ID: <20070503.132411.103006155.davem@davemloft.net>
References: <1178068303.4820.35.camel@dell>
	<1178177448.4909.75.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53002
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031236AbXECUYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 16:24:10 -0400
In-Reply-To: <1178177448.4909.75.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 03 May 2007 00:30:48 -0700

> [BNX2]: Add indirect spinlock.
> 
> The indirect register access method will be used by more than one
> caller in BH context (NAPI poll and timer), so a spinlock is required.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
