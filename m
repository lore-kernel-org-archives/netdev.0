From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/de4x5: remove undefined operations
Date: Mon, 13 Sep 2010 20:03:50 -0700 (PDT)
Message-ID: <20100913.200350.35038394.davem@davemloft.net>
References: <m2r5h0fsfp.fsf@igel.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, kyle@mcmartin.ca, netdev@vger.kernel.org
To: schwab@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49726
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752177Ab0INDDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Sep 2010 23:03:32 -0400
In-Reply-To: <m2r5h0fsfp.fsf@igel.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Schwab <schwab@linux-m68k.org>
Date: Sat, 11 Sep 2010 13:08:58 +0200

> Modifying an object twice without an intervening sequence point is
> undefined.
> 
> Signed-off-by: Andreas Schwab <schwab@linux-m68k.org>

Applied.
