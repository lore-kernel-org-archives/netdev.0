From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH/RFC] remove include/linux/netflinter_ipv6/ip6t_REJECT.h
Date: Fri, 27 Aug 2004 16:59:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040827165902.352fd5df.davem@davemloft.net>
References: <20040828.011451.79815651.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: laforge@gnumonks.org, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040828.011451.79815651.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 28 Aug 2004 01:14:51 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> There're no users of include/linux/netflinter_ipv6/ip6t_REJECT.h,
> which contains wrong, useless definitions.
> 
> Yes, I know ip6t_REJECT.c lives in patch-o-matic, but
> it (almost) completely replaces ip6t_REJECT.h;
> which implies that ip6t_REJECT.h is useless at all.
> 
> So, how about removing ip6t_REJECT.h for now?
> Of course, introducing appropriate ip6t_REJECT.c and ip6t_REJECT.h is
> the alternate option. :-)

I agree, patch applied.
