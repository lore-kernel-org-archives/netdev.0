From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Sun, 13 Mar 2016 23:29:03 -0400 (EDT)
Message-ID: <20160313.232903.1428877113335503120.davem@davemloft.net>
References: <20160311.154046.890043899835986091.davem@davemloft.net>
	<20160311212247.GH1989@uranus.lan>
	<20160311215912.GI1989@uranus.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org, solar@openwall.com,
	vvs@virtuozzo.com, avagin@virtuozzo.com, xemul@virtuozzo.com,
	vdavydov@virtuozzo.com, khorenko@virtuozzo.com,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: gorcunov@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160311215912.GI1989@uranus.lan>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Sat, 12 Mar 2016 00:59:12 +0300

> Here is a cumulative one, which works just brilliant! Thanks a lot, David!
> (I cahcnged reported-by tag, since it's Solar Designer who tell us
>  about the issue, I forgot to mentioned it in first report, very
>  sorry).

Thanks for fixing this up and retesting, applied and queued up for -stable.
