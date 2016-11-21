From: =?gb2312?B?1cXKpL7Z?= <zhangshengju@cmss.chinamobile.com>
Subject: RE: [net-next] rtnl: fix the loop index update error in rtnl_dump_ifinfo()
Date: Mon, 21 Nov 2016 13:12:17 +0800
Message-ID: <001301d243b5$d4eae0b0$7ec0a210$@cmss.chinamobile.com>
References: <1479569312-15224-1-git-send-email-zhangshengju@cmss.chinamobile.com> <20161119.221505.436326824041297337.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="gb2312"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <dsa@cumulusnetworks.com>
To: "'David Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:27850 "EHLO
        cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750744AbcKUFMe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 00:12:34 -0500
In-Reply-To: <20161119.221505.436326824041297337.davem@davemloft.net>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Sunday, November 20, 2016 11:15 AM
> To: zhangshengju@cmss.chinamobile.com
> Cc: netdev@vger.kernel.org; dsa@cumulusnetworks.com
> Subject: Re: [net-next] rtnl: fix the loop index update error in
> rtnl_dump_ifinfo()
> 
> From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> Date: Sat, 19 Nov 2016 23:28:32 +0800
> 
> > If the link is filtered out, loop index should also be updated. If
> > not, loop index will not be correct.
> >
> > Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> 
> Applied to 'net' and queued up for -stable.
> 
> Bug fixes should always be targetted at 'net' not 'net-next'.

Thanks David, I will pay attention to this next time.

BRs,
Zhang Shengju
