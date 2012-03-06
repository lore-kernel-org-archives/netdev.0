From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: [PATCH net-next] net: export netdev_stats_to_stats64
Date: Tue, 6 Mar 2012 13:00:26 +0800
Message-ID: <CABoNC81EyNEX9PeNLF7Z1-0HCvt5nQpHuFpPCowcLfp6hvmOzQ@mail.gmail.com>
References: <20120305113353.GA12969@Spy32>
	<1330954326.2474.9.camel@edumazet-laptop>
	<1330955921.2474.18.camel@edumazet-laptop>
	<CABoNC82c2G+2ubS8it+dAdQBK3EvyaArdGxhZh-KY=3YraMdNA@mail.gmail.com>
	<1331009093.2474.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:42079 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab2CFFA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 00:00:27 -0500
Received: by vbbff1 with SMTP id ff1so4155551vbb.19
        for <netdev@vger.kernel.org>; Mon, 05 Mar 2012 21:00:26 -0800 (PST)
In-Reply-To: <1331009093.2474.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Oops, I misread your mail, I was preparing other stuff, not an add()
> helper. I dont think it would be that usefull (only bond AFAIK)
>

Oh. Yes, it seems only bond benefits from this helper. I won't submit it.

Thanks.

--Junchang
