From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [6/6]: jenkins hash for neigh
Date: Sat, 25 Sep 2004 17:27:12 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040925.172712.30172597.yoshfuji@linux-ipv6.org>
References: <20040925064406.GL3236@sunbeam.de.gnumonks.org>
	<20040925005623.2faf8faf.davem@davemloft.net>
	<20040925.171412.75484376.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: laforge@gnumonks.org, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20040925.171412.75484376.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040925.171412.75484376.yoshfuji@linux-ipv6.org> (at Sat, 25 Sep 2004 17:14:12 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> In article <20040925005623.2faf8faf.davem@davemloft.net> (at Sat, 25 Sep 2004 00:56:23 -0700), "David S. Miller" <davem@davemloft.net> says:
> 
> 
> > +			if (n->nud_state -= NUD_INCOMPLETE &&
> 
> I guess this is typo of:
> 			if (n->nud_state == NUD_INCOMPLETE &&
> 
> Am I wrong?

Sorry, I forgot to state the source; this lives in diff4.

--yoshfuji
