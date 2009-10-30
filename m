From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH kernel 2.6.32-rc5] pcnet_cs: add cis of PreMax PE-200
 ethernet pcmcia card
Date: Thu, 29 Oct 2009 22:51:38 -0700 (PDT)
Message-ID: <20091029.225138.238429920.davem@davemloft.net>
References: <20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
	<20091018103920.ca9217ee.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38373
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754731AbZJ3FvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 01:51:14 -0400
In-Reply-To: <20091018103920.ca9217ee.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Date: Sun, 18 Oct 2009 10:39:20 +0900

> 
> pcnet_cs,serial_cs:
> 
> add cis of PreMax ethernet pcmcia card,
> and some Sierra Wireless serial card(AC555, AC7xx, AC8xx).
> 
> use PROD_ID for AC7xx, because MANF_ID of AC7xx and AC8xx are the same.
> 
> 
> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

Applied to net-2.6, thanks.
