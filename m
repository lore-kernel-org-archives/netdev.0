From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skge: use the DMA state API instead of the pci
 equivalents
Date: Sat, 15 May 2010 23:29:51 -0700 (PDT)
Message-ID: <20100515.232951.43050353.davem@davemloft.net>
References: <20100428095730K.fujita.tomonori@lab.ntt.co.jp>
	<20100514183307.6c14f294@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45690
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752324Ab0EPG3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 02:29:42 -0400
In-Reply-To: <20100514183307.6c14f294@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 14 May 2010 18:33:07 -0700

> On Wed, 28 Apr 2010 09:57:04 +0900
> FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:
> 
>> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> 
> Yes, this works fine. Sorry for the delay but that test system
> was offline for several months and the disk went bad.
> 
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
