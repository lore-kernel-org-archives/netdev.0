From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance tests
Date: Tue, 17 Jun 2003 19:29:25 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <16111.20469.376899.55240@robur.slu.se>
References: <20030616234937.GE18484@netnation.com>
	<20030617.085921.28790392.davem@redhat.com>
	<16111.18107.699689.704597@robur.slu.se>
	<20030617.095028.35014188.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, sim@netnation.com, ralph+d@istop.com,
	hadi@shell.cyberus.ca, xerox@foonet.net, fw@deneb.enyo.de,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030617.095028.35014188.davem@redhat.com>
List-Id: netdev.vger.kernel.org


David S. Miller writes:

 >     Internet-routing and made a script so it can be used for
 >     experiments. I can make it available.
 > 
 > Please do, I'd like to play with such a list locally.


ftp://robur.slu.se/pub/Linux/net-development/inet_routes/
Just configure the script and run...

And Simon can you do a run with this routing table too? And even fibstat 
output could be interesting to compare.


Cheers.

						--ro


