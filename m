From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH|RFC] IPv6 netfilter: a module for complete proxy ND
 support
Date: Wed, 14 Jan 2004 21:04:27 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040114.210427.104284595.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.58.0401141250470.24125@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, davem@redhat.com, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: vnuorval@tcs.hut.fi
In-Reply-To: <Pine.LNX.4.58.0401141250470.24125@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.58.0401141250470.24125@rhea.tcs.hut.fi> (at Wed, 14 Jan 2004 13:25:42 +0200 (EET)), Ville Nuorvala <vnuorval@tcs.hut.fi> says:

> the packets for local processing. I think the cleanest solution for this
> is a netfilter module (which I have incidentally written already :)

I don't think so. Proxy should not depend on netfilter.

--yoshfuji
