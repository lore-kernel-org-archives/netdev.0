From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [6/6]: jenkins hash for neigh
Date: Sat, 25 Sep 2004 17:14:12 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040925.171412.75484376.yoshfuji@linux-ipv6.org>
References: <20040924142702.62a2b23d.davem@davemloft.net>
	<20040925064406.GL3236@sunbeam.de.gnumonks.org>
	<20040925005623.2faf8faf.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: laforge@gnumonks.org, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20040925005623.2faf8faf.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040925005623.2faf8faf.davem@davemloft.net> (at Sat, 25 Sep 2004 00:56:23 -0700), "David S. Miller" <davem@davemloft.net> says:


> +			if (n->nud_state -= NUD_INCOMPLETE &&

I guess this is typo of:
			if (n->nud_state == NUD_INCOMPLETE &&

Am I wrong?

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
