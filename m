From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [Fwd: [E1000] NAPI re-insertion w/ changes]
Date: Fri, 28 Mar 2003 09:27:38 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16004.1914.582979.278009@robur.slu.se>
References: <16003.11449.497905.815776@robur.slu.se>
	<slrnb86c3g.7vo.lunz@stoli.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jason Lunz <lunz@falooley.org>
In-Reply-To: <slrnb86c3g.7vo.lunz@stoli.localnet>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jason Lunz writes:

 > I've seen pretty much the same thing. I plotted throughput vs. offered
 > load for e1000 4.4.12-k1, 4.4.19-k3, and 5.0.43-k1 (all backported to
 > 2.4.20). A summary with graphs is at:
 > 
 > http://gtf.org/lunz/linux/net/perf/
 
 Illustrative.

 > 5.0.43 seems to be a significant regression, both in terms of throughput
 > and CPU load.
 
 Can you test the patch I sent for 5.0.43 with your equipment/setup?
 

 Cheers.
						--ro
