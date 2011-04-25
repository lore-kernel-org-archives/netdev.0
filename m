From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] be2net: Fixed a bug in be_cmd_get_regs().
Date: Mon, 25 Apr 2011 12:14:00 -0700 (PDT)
Message-ID: <20110425.121400.104054960.davem@davemloft.net>
References: <8a31447a-9317-4569-ae2b-865feb9ce594@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46660
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758203Ab1DYTOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 15:14:34 -0400
In-Reply-To: <8a31447a-9317-4569-ae2b-865feb9ce594@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Thu, 21 Apr 2011 18:48:12 +0530

> Resending patch as the 'changelog' got missed out in my previous submission.
> 
> Same WRB entry was being reused over different iterations of a 
> loop while issuing non-embedded IOCTL requests.Fixed couple of minor bugs 
> in this path as well.
> Re-factored code to alloc/free memory for DMA outside of loop
> 
> 
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>

Applied, thanks.
