From: Jingoo Han <jg1.han@samsung.com>
Subject: Re: [PATCH 20/52] net: fealnx: remove unnecessary pci_set_drvdata()
Date: Thu, 12 Sep 2013 14:49:56 +0900
Message-ID: <000601ceaf7b$e8e7b2e0$bab718a0$%han@samsung.com>
References: <005e01ceaec2$23e32420$6ba96c60$%han@samsung.com>
 <5230B435.2050908@cogentembedded.com>
 <000e01ceaf4c$90cde130$b269a390$%han@samsung.com>
 <20130912.012443.2294235053428746280.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	'Jingoo Han' <jg1.han@samsung.com>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:47907 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752596Ab3ILFuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 01:50:07 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MT000FAJ06OI3F0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Thu, 12 Sep 2013 14:49:56 +0900 (KST)
In-reply-to: <20130912.012443.2294235053428746280.davem@davemloft.net>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, September 12, 2013 2:25 PM, David Miller wrote:
> On Thu, 12 Sep 2013 09:11:01 +0900, Jingoo Han wrote:
> > Would you let know the reason not to add coding style fixes?
> 
> They should be made seperately so that the individual changes
> can be reviewed more easily and without unnecessary unrelated
> changes mixed in.

OK, I see. :-)
Thank you for your answer.
Then, I will send V2 patch soon.

Best regards,
Jingoo Han
