From: Jingoo Han <jg1.han@samsung.com>
Subject: Re: [PATCH 1/5] net: emac: use platform_{get,set}_drvdata()
Date: Wed, 04 Sep 2013 12:00:18 +0900
Message-ID: <000901cea91a$e36f5050$aa4df0f0$%han@samsung.com>
References: <000f01cea7b3$6226fd30$2674f790$%han@samsung.com>
 <20130903.224003.792091851244921220.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com,
	'Jingoo Han' <jg1.han@samsung.com>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:44823 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761683Ab3IDDAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 23:00:21 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSK001J0Z09GCF0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Wed, 04 Sep 2013 12:00:19 +0900 (KST)
In-reply-to: <20130903.224003.792091851244921220.davem@davemloft.net>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, September 04, 2013 11:40 AM, David Miller wrote:
> 
> From: Jingoo Han <jg1.han@samsung.com>
> Date: Mon, 02 Sep 2013 17:06:52 +0900
> 
> > Use the wrapper functions for getting and setting the driver data
> > using platform_device instead of using dev_{get,set}_drvdata()
> > with &pdev->dev, so we can directly pass a struct platform_device.
> > This is a purely cosmetic change.
> >
> > Signed-off-by: Jingoo Han <jg1.han@samsung.com>
> 
> All 5 patches applied.
> 
> Please, in the future, provide an initial "[PATCH 00/nn] " posting for
> a series of patches, giving a top-level description of what is happening.

OK, I will provide an initial "[PATCH 00/nn]" posting.
Thank you for your suggestion. :-)

Best regards,
Jingoo Han

> 
> This way I can include that commit message text in a merge commit and
> also I have an appropriate email to reply to if I just want to say
> that I applied everything in the series.
