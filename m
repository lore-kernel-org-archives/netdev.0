From: "Mr. James W. Laferriere" <babydr@baby-dragons.com>
Subject: Re: Route cache performance tests
Date: Tue, 17 Jun 2003 15:06:43 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.56.0306171459230.6807@filesrv1.baby-dragons.com>
References: <20030616234937.GE18484@netnation.com> <20030617.085921.28790392.davem@redhat.com>
 <16111.18107.699689.704597@robur.slu.se> <20030617.095028.35014188.davem@redhat.com>
 <16111.20469.376899.55240@robur.slu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Linux networking maillist <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16111.20469.376899.55240@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

	Hello Robert ,  First thank you for these tools .  Now for the
	questions .

	Is 'fibstat' only for 2.5.x kernels ?
	The reason for that ? is there isn't a /proc/net/fib_stat .
	Under 2.4.21 , which has no mention of fib_stat anywhere in the
	sources .

	The next ? is packet-generator.c (appears) to require kernel
	include files .  Is there an updated user level net/ includes ?

		Tia ,  JimL
On Tue, 17 Jun 2003, Robert Olsson wrote:
> David S. Miller writes:
>  >     Internet-routing and made a script so it can be used for
>  >     experiments. I can make it available.
>  > Please do, I'd like to play with such a list locally.

> ftp://robur.slu.se/pub/Linux/net-development/inet_routes/
> Just configure the script and run...

> And Simon can you do a run with this routing table too? And even fibstat
> output could be interesting to compare.
-- 
       +------------------------------------------------------------------+
       | James   W.   Laferriere | System    Techniques | Give me VMS     |
       | Network        Engineer |     P.O. Box 854     |  Give me Linux  |
       | babydr@baby-dragons.com | Coudersport PA 16915 |   only  on  AXP |
       +------------------------------------------------------------------+
