From: James Morris <jmorris@intercode.com.au>
Subject: Re: FIN_WAIT1 / TCP_CORK / 2.2 -- reproducible bug and test case
Date: Sat, 5 Oct 2002 21:53:40 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0210052152400.25151-100000@blackbird.intercode.com.au>
References: <20021005075157.GC2531@samba.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Pool <mbp@samba.org>
In-Reply-To: <20021005075157.GC2531@samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 5 Oct 2002, Martin Pool wrote:

> The machine inside VMware is as shown below.  This was originally
> reported by a distcc user who was apparently experiencing the problem
> on diverse hardware on a 100Mbps switched network.
> 
> Did you see the example code that I posted at the start of the thread?

Yep.

> I can't reproduce it locally, but I can reproduce it going to a 2.4.18
> machine across a 100Mbps switched network.  A tcpdump (complete?) is
> attached.

Thanks for the extra info.

- James
-- 
James Morris
<jmorris@intercode.com.au>
