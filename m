From: "David S. Miller" <davem@davemloft.net>
Subject: Re: ipv6 unresolved symbol
Date: Tue, 15 Mar 2005 10:25:43 -0800
Message-ID: <20050315102543.6f59dd15.davem@davemloft.net>
References: <Pine.SOC.4.61.0503151136260.428@math.ut.ee>
	<20050315.185815.12690947.yoshfuji@linux-ipv6.org>
	<20050315134002.GE3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, mroos@linux.ee, netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050315134002.GE3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Mar 2005 14:40:02 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> * YOSHIFUJI Hideaki / ?$B5HF#1QL@ <20050315.185815.12690947.yoshfuji@linux-ipv6.org> 2005-03-15 18:58
> > In article <Pine.SOC.4.61.0503151136260.428@math.ut.ee> (at Tue, 15 Mar 2005 11:36:42 +0200 (EET)), Meelis Roos <mroos@linux.ee> says:
> > 
> > > This is todays 2.6.11+BK on x86 with modular ipv6:
> > > 
> > > WARNING: /lib/modules/2.6.11/kernel/net/ipv6/ipv6.ko needs unknown symbol dev_get_flags
> > 
> > Oops, thanks.
> 
> Stupid me, should have checked that, thanks for the fix.

No worries.  Andrew Morton sent me this fix a few hours ago so it's
already in my tree and about to be sent to Linus.
