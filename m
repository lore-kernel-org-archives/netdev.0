From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 3/8] net_sched: mirred: remove action when
 the target device is gone
Date: Mon, 23 Dec 2013 18:05:54 -0500
Message-ID: <52B8C1D2.9070100@mojatatu.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>	<1387167311-14763-4-git-send-email-xiyou.wangcong@gmail.com>	<52B1B1B1.2060501@mojatatu.com>	<CAM_iQpUDZa-=H53Csg8476xOL0xP+rn85O8eB1O39-eF_Jo+uw@mail.gmail.com>	<52B1FC6D.7040005@mojatatu.com>	<CAM_iQpWxCShCgiBrraJ3h9qzgVU82quq0E5vmFMSEcgEwSctJQ@mail.gmail.com>	<52B71024.3090504@mojatatu.com>	<CAM_iQpW9kUzip+p8fCkD4wH7KbAv8aR-Fqa0iRwPYdzk8+4Tqw@mail.gmail.com>	<52B74C3A.1050900@mojatatu.com>	<CAM_iQpXddH4qX2+-mY5gWLU19b6zjZzKV_RvQiyTT8sJ1sq-ow@mail.gmail.com>	<52B82F80.8070902@mojatatu.com>	<CAM_iQpUfKcS6RDmV_p+0tEgxx6Z2Y2k9m-VxxwwpL+PB0TX96Q@mail.gmail.com>	<52B89FEB.9090503@mojatatu.com>	<CAM_iQpWarY7kHNCtVdYqMVdADFbCUmDsAVQz1+iEx9JKsdZN5w@mail.gmail.com>	<52B8B98C.7050200@mojatatu.com> <CAM_iQpXPLppL1E0d5nFfbM2hzd
 _-2+zqiU6zpN0b8Xo+XhVHCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:39617 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932309Ab3LWXF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 18:05:56 -0500
Received: by mail-ie0-f169.google.com with SMTP id e14so6537968iej.14
        for <netdev@vger.kernel.org>; Mon, 23 Dec 2013 15:05:56 -0800 (PST)
In-Reply-To: <CAM_iQpXPLppL1E0d5nFfbM2hzd_-2+zqiU6zpN0b8Xo+XhVHCA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/23/13 17:51, Cong Wang wrote:

[..]

> Great! Then show me how to do remove a mirred action upon
> the target device is gone in user-space, please?

[..]

> Your replies show you care about policy vs mechanism very much,
> but you even don't do any thing with either 1) try to show me how
> the user-space implements it or 2) go head to make same mechanism
> for filters (and qdisc) as well.
>
> Do something to prove that you said. :) Otherwise, I think you are kidding
> me.
>

No disrespect intended Cong - but lets just end this discussion agreeing
to disagree. On my side I violently disagree. I hope not to spend any
more energy on this.

cheers,
jamal
