From: Jingoo Han <jg1.han@samsung.com>
Subject: Re: [PATCH 20/52] net: fealnx: remove unnecessary pci_set_drvdata()
Date: Thu, 12 Sep 2013 16:54:14 +0900
Message-ID: <000001ceaf8d$46951cf0$d3bf56d0$%han@samsung.com>
References: <000e01ceaf4c$90cde130$b269a390$%han@samsung.com>
 <20130912.012443.2294235053428746280.davem@davemloft.net>
 <000601ceaf7b$e8e7b2e0$bab718a0$%han@samsung.com>
 <20130912.033606.1689936899104585741.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	'Jingoo Han' <jg1.han@samsung.com>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:16473 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756434Ab3ILHyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 03:54:16 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MT000D935W0ODD0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Thu, 12 Sep 2013 16:54:14 +0900 (KST)
In-reply-to: <20130912.033606.1689936899104585741.davem@davemloft.net>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, September 12, 2013 4:36 PM, David Miller wrote:
> On Thu, 12 Sep 2013 14:49:56 +0900, Jingoo Han wrote:
> > On Thursday, September 12, 2013 2:25 PM, David Miller wrote:
> >> On Thu, 12 Sep 2013 09:11:01 +0900, Jingoo Han wrote:
> >> > Would you let know the reason not to add coding style fixes?
> >>
> >> They should be made seperately so that the individual changes
> >> can be reviewed more easily and without unnecessary unrelated
> >> changes mixed in.
> >
> > OK, I see. :-)
> > Thank you for your answer.
> > Then, I will send V2 patch soon.
> 
> Please do not submit such a huge patch series in the future.
> 
> Anything more than 16 patches at a time is not reasonable and
> overloads reviewer's capacity to look at your changes.
> 

Then, in this case,
I have to split the patches into several chunks, and send them
over few weeks?
For example,
  one day: 15 patches
  2 weeks later: 15 patches
  2 weeks later: 15 patches
  2 weeks later: 7 patches

Best regards,
Jingoo Han
