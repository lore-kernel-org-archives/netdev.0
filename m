From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/16][BNX2]: Block MII access when ifdown.
Date: Thu, 03 May 2007 13:18:09 -0700 (PDT)
Message-ID: <20070503.131809.54975541.davem@davemloft.net>
References: <1178068303.4820.35.camel@dell>
	<1178177286.4909.65.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50572
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754294AbXECUSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 16:18:09 -0400
In-Reply-To: <1178177286.4909.65.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 03 May 2007 00:28:06 -0700

> [BNX2]: Block MII access when ifdown.
> 
> The device may be in D3hot state and should not allow MII register
> access.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
