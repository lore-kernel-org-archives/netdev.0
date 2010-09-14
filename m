From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/cxgb3: remove undefined operations
Date: Mon, 13 Sep 2010 20:03:55 -0700 (PDT)
Message-ID: <20100913.200355.15243956.davem@davemloft.net>
References: <m2mxrofs9p.fsf@igel.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, netdev@vger.kernel.org
To: schwab@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49734
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753449Ab0INDDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Sep 2010 23:03:37 -0400
In-Reply-To: <m2mxrofs9p.fsf@igel.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Schwab <schwab@linux-m68k.org>
Date: Sat, 11 Sep 2010 13:12:34 +0200

> Modifying an object twice without an intervening sequence point is
> undefined.
> 
> Signed-off-by: Andreas Schwab <schwab@linux-m68k.org>

Applied.
