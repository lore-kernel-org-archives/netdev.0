From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/3] net_sched: act: Dont increment refcnt on
 replace
Date: Thu, 26 Dec 2013 06:58:32 -0500
Message-ID: <52BC19E8.5010602@mojatatu.com>
References: <1387803733-19709-1-git-send-email-jhs@mojatatu.com>	<1387803733-19709-2-git-send-email-jhs@mojatatu.com> <CAM_iQpX2QqJx1eg-P5G5WQq8b-CwwJS0t4Mqb67dbFb_RuZtyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:62780 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944Ab3LZL7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 06:59:00 -0500
Received: by mail-ig0-f177.google.com with SMTP id uy17so19399416igb.4
        for <netdev@vger.kernel.org>; Thu, 26 Dec 2013 03:59:00 -0800 (PST)
In-Reply-To: <CAM_iQpX2QqJx1eg-P5G5WQq8b-CwwJS0t4Mqb67dbFb_RuZtyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/23/13 19:41, Cong Wang wrote:

>
> Therefore should go to net rather than net-next?
>

I asked that question to Dave. Will let him call it.
This one sits on patches that are on top of net-next.

cheers,
jamal
