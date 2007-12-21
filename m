From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/9][BNX2]: Add support for a new tx ring.
Date: Thu, 20 Dec 2007 20:01:30 -0800 (PST)
Message-ID: <20071220.200130.67351964.davem@davemloft.net>
References: <1198182780.9163.33.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56292
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754043AbXLUEBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 23:01:30 -0500
In-Reply-To: <1198182780.9163.33.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 20 Dec 2007 12:33:00 -0800

> [BNX2]: Add support for a new tx ring.
> 
> To separate TX IRQs into a different MSIX vector, we need to
> support a new tx ring.  The original tx ring will still be used
> when not using MSIX.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.

