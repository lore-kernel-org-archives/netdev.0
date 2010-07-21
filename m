From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/3] drivers/net/cxgb3/t3_hw.c: use new hex_to_bin()
 method
Date: Wed, 21 Jul 2010 11:17:23 -0700 (PDT)
Message-ID: <20100721.111723.46356003.davem@davemloft.net>
References: <201007202225.o6KMPGnA021443@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ext-andriy.shevchenko@nokia.com,
	divy@chelsio.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54952
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751170Ab0GUSRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 14:17:07 -0400
In-Reply-To: <201007202225.o6KMPGnA021443@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Tue, 20 Jul 2010 15:25:16 -0700

> From: Andy Shevchenko <ext-andriy.shevchenko@nokia.com>
> 
> Get rid of own implementation of hex_to_bin().
> 
> Signed-off-by: Andy Shevchenko <ext-andriy.shevchenko@nokia.com>
> Acked-by: Divy Le Ray <divy@chelsio.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
