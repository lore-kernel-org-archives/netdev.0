From: Chris Wright <chrisw@osdl.org>
Subject: Re: [PATCH] IPV4: spelling correction
Date: Tue, 10 Feb 2004 10:34:55 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040210103455.B17871@osdlab.pdx.osdl.net>
References: <20040211.032831.67897970.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@?(B" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040211.032831.67897970.yoshfuji@linux-ipv6.org>; from yoshfuji@linux-ipv6.org on Wed, Feb 11, 2004 at 03:28:31AM +0900
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* YOSHIFUJI Hideaki / ?$B5HF#1QL@?(B (yoshfuji@linux-ipv6.org) wrote:
> --- 1.34/net/ipv4/ip_gre.c	Tue Oct 28 18:13:14 2003
> +++ edited/net/ipv4/ip_gre.c	Wed Feb 11 02:57:54 2004
> @@ -316,8 +316,8 @@
>     GRE tunnels with enabled checksum. Tell them "thank you".
>  
>     Well, I wonder, rfc1812 was written by Cisco employee,
> -   what the hell these idiots break standrads established
> -   by themself???
> +   what the hell these idiots break standrards established
                                       ^^^^^^^^^^
> +   by themselves???

Heh, looks like swapping one typo for another.  standards?

> @@ -392,7 +392,7 @@
>  			if (tp->ack.ato > tp->rto)
>  				tp->ack.ato = tp->rto;
>  		} else if (m > tp->rto) {
> -			/* Too long gap. Apparently sender falled to
> +			/* Too long gap. Apparently sender fellen to
							   ^^^^^^
failed?

>  			 * restart window, so that we send ACKs quickly.

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net
