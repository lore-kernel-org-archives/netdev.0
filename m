From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: RE: [PATCH] bnx2x: use the dma state API instead of the pci
 equivalents
Date: Tue, 6 Apr 2010 16:41:18 +0300
Message-ID: <1270561278.1848.5.camel@lb-tlvb-eilong.il.broadcom.com>
References: <8628FE4E7912BF47A96AE7DD7BAC0AADDDC525ADDC@SJEXCHCCR02.corp.ad.broadcom.com>
 <20100404190116N.fujita.tomonori@lab.ntt.co.jp>
 <8628FE4E7912BF47A96AE7DD7BAC0AADDDC525ADDD@SJEXCHCCR02.corp.ad.broadcom.com>
 <20100404205028H.fujita.tomonori@lab.ntt.co.jp>
 <8628FE4E7912BF47A96AE7DD7BAC0AADDDC525AF62@SJEXCHCCR02.corp.ad.broadcom.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: "FUJITA Tomonori" <fujita.tomonori@lab.ntt.co.jp>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2385 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754567Ab0DFNlZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Apr 2010 09:41:25 -0400
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AADDDC525AF62@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-04-06 at 00:39 -0700, Vladislav Zolotarov wrote:
> Thanks, Fujita.
> 
> The patch looks fine. I'll run some regression tests on the patched driver to check that things still work and if it's ok we will ack it shortly.
> 
> vlad
> 
> 

> > =
> > From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> > Subject: [PATCH] bnx2x: use the DMA API instead of the pci equivalents
> >
> > The DMA API is preferred.
> >
> > Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Vlad's testing with this patch were finished successfully.

Thanks Fujita!
Acked-by: Vladislav Zolotarov <vladz@broadcom.com>
Acked-by: Eilon Greenstein <eilong@broadcom.com>


