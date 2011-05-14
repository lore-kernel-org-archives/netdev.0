From: Maxin B John <maxin.john@gmail.com>
Subject: Re: [PATCH] net: ipv6: mcast: Removing invalid check
Date: Sat, 14 May 2011 17:45:39 +0300
Message-ID: <BANLkTikeeBdFrnPX7J=uRswFZm-mwUxh=w@mail.gmail.com>
References: <20110514134307.GA3603@maxin>
	<1305383610.3120.62.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net, yoshfuji@linux-ipv6.org, jmorris@namei.org,
	pekkas@netcore.fi, kuznet@ms2.inr.ac.ru, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305383610.3120.62.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> At a first glance, I would say Coverity is wrong, unless you can explain
> why it's right ;)
>
> first can be 0 at this point, we are in a loop.

You are right.

> BTW "Removing invalid check" is a really wrong patch title.
>
> Once you can prove your point, you should use "Remove useless check"
>

I will keep it in mind. Thanks .

Best Regards,
Maxin B John
