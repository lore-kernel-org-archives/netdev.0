From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: Re: [RFC PATCH] bridge: netfilter: fix skb->nf_bridge NULL panic in br_nf_forward_finish
Date: Tue, 10 Jul 2012 16:34:26 +0800
Message-ID: <CAF1ivSaYQ1YspOfJDi7S1MqvZ2LC1__o4+z4dexD6Z7nuX-oSQ@mail.gmail.com>
References: <1341584394.4789.34.camel@chief-river-32>
	<4FFAA3CE.1090504@navynet.it>
	<CAF1ivSZBMWYc5iKxhX5d_ykkMD4LauFP9M10dBwfmqvpYj=pHg@mail.gmail.com>
	<4FFBD289.7050909@navynet.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Massimo Cetra <ctrix+debianbugs@navynet.it>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>
To: Massimo Cetra <mcetra@navynet.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [124.207.24.138] ([124.207.24.138]:59162 "EHLO
	mail.ss.pku.edu.cn" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753849Ab2GJIfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 04:35:12 -0400
Received: from mail-vc0-f174.google.com (mail-vc0-f174.google.com [209.85.220.174])
	(Authenticated sender: mlin@ss.pku.edu.cn)
	by mail.ss.pku.edu.cn (Postfix) with ESMTPA id D3C9DDBCB4
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 16:34:30 +0800 (CST)
Received: by vcbf11 with SMTP id f11so7850318vcb.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 01:34:26 -0700 (PDT)
In-Reply-To: <4FFBD289.7050909@navynet.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 10, 2012 at 2:58 PM, Massimo Cetra <mcetra@navynet.it> wrote:
> On 09/07/2012 14:00, Lin Ming wrote:
>
>>> i spent a couple of days trying to figure out how to reproduce but you
>>> were
>>> quicker and smarter than me.
>>
>>
>> Could you also test it ? :-)
>>
>
> Of course.
>
> I have already installed a 3.5-rc and a 3.2.22 with this patch and, by now,
> i see no problems.
>
> I'm only waiting a couple of days before reporting, to be sure the issue is
> gone.

Then could you reply to below thread after you confirm the issue is gone?

http://marc.info/?l=linux-netdev&m=134165707424765&w=2

Nice to add your "Reported-and-tested-by:".

Thanks,
Lin Ming

>
>
> Massimo
