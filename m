From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qla3xxx: use the DMA state API instead of the pci
 equivalents
Date: Tue, 13 Apr 2010 02:54:38 -0700 (PDT)
Message-ID: <20100413.025438.174984130.davem@davemloft.net>
References: <1271118734-28353-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
	<1271118734-28353-5-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: fujita.tomonori@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45807
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752273Ab0DMJye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 05:54:34 -0400
In-Reply-To: <1271118734-28353-5-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Tue, 13 Apr 2010 09:32:13 +0900

> This replace the PCI DMA state API (include/linux/pci-dma.h) with the
> DMA equivalents since the PCI DMA state API will be obsolete.
> 
> No functional change.
> 
> For further information about the background:
> 
> http://marc.info/?l=linux-netdev&m=127037540020276&w=2
> 
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

Applied.
