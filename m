From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] NETDEBUG network triggerable messages in IPv6
Date: Fri, 9 Apr 2004 20:24:38 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040409202438.5ff80565.ak@suse.de>
References: <20040409193123.63e4cdc7.ak@suse.de>
	<20040410.024705.97089877.yoshfuji@linux-ipv6.org>
	<20040409195052.10ba931c.ak@suse.de>
	<20040410.030904.82108741.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040410.030904.82108741.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 10 Apr 2004 03:09:04 +0900 (JST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> In article <20040409195052.10ba931c.ak@suse.de> (at Fri, 9 Apr 2004 19:50:52 +0200), Andi Kleen <ak@suse.de> says:
> 
> > >   NETDEBUG_PRINTK_LIMIT("overrun destopt\n"..)
> > > 
> > > (or something like this) much more.
> > 
> > ... and this will make the lines even longer.
> 
> If you mind that, you can use shorter name 
> like IP6DEBUG / IP6DEBUG_LIMIT() etc.

Yes, I opted for NETDEBUG_LIMIT.

-Andi
