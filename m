From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: use the dma state API instead of the pci
 equivalents
Date: Wed, 07 Apr 2010 21:06:03 -0700 (PDT)
Message-ID: <20100407.210603.133014159.davem@davemloft.net>
References: <20100404205028H.fujita.tomonori@lab.ntt.co.jp>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDC525AF62@SJEXCHCCR02.corp.ad.broadcom.com>
	<1270561278.1848.5.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	vladz@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43732
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751120Ab0DHEGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 00:06:00 -0400
In-Reply-To: <1270561278.1848.5.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Tue, 6 Apr 2010 16:41:18 +0300

> On Tue, 2010-04-06 at 00:39 -0700, Vladislav Zolotarov wrote:
>> Thanks, Fujita.
>> 
>> The patch looks fine. I'll run some regression tests on the patched driver to check that things still work and if it's ok we will ack it shortly.
>> 
>> vlad
>> 
>> 
> 
>> > =
>> > From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
>> > Subject: [PATCH] bnx2x: use the DMA API instead of the pci equivalents
>> >
>> > The DMA API is preferred.
>> >
>> > Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> Vlad's testing with this patch were finished successfully.
> 
> Thanks Fujita!
> Acked-by: Vladislav Zolotarov <vladz@broadcom.com>
> Acked-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks.
