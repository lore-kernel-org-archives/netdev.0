From: =?gb2312?B?1cXKpL7Z?= <zhangshengju@cmss.chinamobile.com>
Subject: Re: [net-next 1/2] bonding: remove duplicate set of flag IFF_MULTICAST
Date: Wed, 16 Mar 2016 20:30:14 +0800
Message-ID: <000b01d17f7f$986e61c0$c94b2540$@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <gospo@cumulusnetworks.com>,
	"'Veaceslav Falico'" <vfalico@gmail.com>, <davem@davemloft.net>,
	<j.vosburgh@gmail.com>, <jiri@resnulli.us>
To: "'Nikolay Aleksandrov'" <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:8343 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111AbcCPMa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 08:30:27 -0400
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On 03/16/2016 10:59 AM, Zhang Shengju wrote:
> > Remove unnecessary set of flag IFF_MULTICAST, since ether_setup
> > already does this.
> >
> > Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> > ---
> >  drivers/net/bonding/bond_main.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> 
> There're a few more bonding maintainers, I've added them to the CC list.
> 
> Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Thanks, Nikolay.
