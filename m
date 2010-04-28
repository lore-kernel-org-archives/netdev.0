From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: use the DMA state API instead of the pci
 equivalents
Date: Wed, 28 Apr 2010 10:07:53 -0700 (PDT)
Message-ID: <20100428.100753.94869534.davem@davemloft.net>
References: <20100428095826S.fujita.tomonori@lab.ntt.co.jp>
	<20100428090816.39436663@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60100
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753862Ab0D1RHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 13:07:51 -0400
In-Reply-To: <20100428090816.39436663@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 28 Apr 2010 09:08:16 -0700

> On Wed, 28 Apr 2010 09:57:05 +0900
> FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:
> 
>> This replace the PCI DMA state API (include/linux/pci-dma.h) with the
>> DMA equivalents since the PCI DMA state API will be obsolete.
>> 
>> No functional change.
>> 
>> For further information about the background:
>> 
>> http://marc.info/?l=linux-netdev&m=127037540020276&w=2
>> 
>> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> 
> Tested, this works thanks.
> 
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
