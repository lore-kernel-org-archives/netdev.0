From: Tim Gardner <timg@tpi.com>
Subject: Re: [PATCH + RFC] neighbour/ARP cache scalability
Date: Tue, 21 Sep 2004 11:58:27 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095789507.3934.69.camel@tim.rtg.net>
References: <20040922.001448.73843048.yoshfuji@linux-ipv6.org>
	 <Pine.LNX.4.44.0409211856260.9906-100000@netcore.fi>
	 <20040922.010428.104988024.yoshfuji@linux-ipv6.org>
	 <1095784761.3934.52.camel@tim.rtg.net>
	 <20040921173134.GC12132@wotan.suse.de>
Reply-To: timg@tpi.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>,
        pekkas@netcore.fi, laforge@gnumonks.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040921173134.GC12132@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-21 at 11:31, Andi Kleen wrote:

> But also allows an easy DOS. Someone just has to spoof a lot of connections
> attempts with the source address of your primary name server or 
> some other important service.
> 

That is what other iptables rules and filters are for. I get thousands
of source address spoofs from my Internet connection every day. Network
security is a layered approach.

rtg
-- 
timg@tpi.com http://www.tpi.com
406-443-5357(MT) 503-601-0234(OR)
