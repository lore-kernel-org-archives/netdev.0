From: Thomas Graf <tgraf@suug.ch>
Subject: Re: ipv6 unresolved symbol
Date: Tue, 15 Mar 2005 14:40:02 +0100
Message-ID: <20050315134002.GE3086@postel.suug.ch>
References: <Pine.SOC.4.61.0503151136260.428@math.ut.ee> <20050315.185815.12690947.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mroos@linux.ee, davem@davemloft.net, netdev@oss.sgi.com
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20050315.185815.12690947.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* YOSHIFUJI Hideaki / ?$B5HF#1QL@ <20050315.185815.12690947.yoshfuji@linux-ipv6.org> 2005-03-15 18:58
> In article <Pine.SOC.4.61.0503151136260.428@math.ut.ee> (at Tue, 15 Mar 2005 11:36:42 +0200 (EET)), Meelis Roos <mroos@linux.ee> says:
> 
> > This is todays 2.6.11+BK on x86 with modular ipv6:
> > 
> > WARNING: /lib/modules/2.6.11/kernel/net/ipv6/ipv6.ko needs unknown symbol dev_get_flags
> 
> Oops, thanks.

Stupid me, should have checked that, thanks for the fix.
