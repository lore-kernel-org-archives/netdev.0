From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH net 00/19] net: hns: Misc. HNS Bug Fixes & Code
 Improvements
Date: Thu, 30 Mar 2017 17:19:44 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F91A8E1855@lhreml503-mbx>
References: <20170330153106.14344-1-salil.mehta@huawei.com>
 <20170330.100852.631078039848764955.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lhrrgout.huawei.com ([194.213.3.17]:17061 "EHLO
        lhrrgout.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932582AbdC3RUA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 13:20:00 -0400
In-Reply-To: <20170330.100852.631078039848764955.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, March 30, 2017 6:09 PM
> To: Salil Mehta
> Cc: Zhuangyuzeng (Yisen); mehta.salil.lnk@gmail.com;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH net 00/19] net: hns: Misc. HNS Bug Fixes & Code
> Improvements
> 
> From: Salil Mehta <salil.mehta@huawei.com>
> Date: Thu, 30 Mar 2017 16:30:47 +0100
> 
> > This patch set introduces various HNS bug fixes, optimizations and code
> > improvements.
> 
> What tree are you targetting?
> 
> You say "net" in your Subject lines, but this series has cleanups and all
> sorts
> of other things which are absolutely not appropriate for 'net' and are
> 'net-next'
> material.
Hi David,
Sorry David, These bug fixes are for the next merge window and for net-next.
Should I resend the patches with below change?

>>>>[PATCH net-next 00/19] net: hns: Misc. HNS Bug Fixes & Code Improvements  

Best regards
Salil
