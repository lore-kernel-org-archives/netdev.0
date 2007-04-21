From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7] [IrDA] af_irda: IRDA_ASSERT cleanups
Date: Fri, 20 Apr 2007 22:10:24 -0700 (PDT)
Message-ID: <20070420.221024.14203036.davem@davemloft.net>
References: <20070418213202.214829666@sortiz.org>
	<20070418214751.145259810@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55789
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754473AbXDUFKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2007 01:10:21 -0400
In-Reply-To: <20070418214751.145259810@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: samuel@sortiz.org
Date: Thu, 19 Apr 2007 00:32:06 +0300

> In af_irda.c, the multiple IRDA_ASSERT() are either hiding bugs, useless, or
> returning the wrong value.
> Let's clean that up.
> 
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Applied to net-2.6.22, thanks.
