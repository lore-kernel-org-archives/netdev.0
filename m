From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance tests
Date: Tue, 17 Jun 2003 18:50:03 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <16111.18107.699689.704597@robur.slu.se>
References: <20030616.160856.35828947.davem@redhat.com>
	<20030616232750.GD18484@netnation.com>
	<20030616234937.GE18484@netnation.com>
	<20030617.085921.28790392.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sim@netnation.com, ralph+d@istop.com, hadi@shell.cyberus.ca,
	xerox@foonet.net, fw@deneb.enyo.de, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030617.085921.28790392.davem@redhat.com>
List-Id: netdev.vger.kernel.org


David S. Miller writes:

 >    60.0073 seconds passed, avg forwarding rate: 157557.710 pps

 > To be honest, this isn't half-bad for pure DoS load.

 No thats pretty good and profiles looks as expected. It would interesting
 to get the singeflow performance as a comparison.

 Also think Simon used only /32 routes... I took "real" Internet-routing
 and made a script so it can be used for experiments. I can make it available.

 Cheers.

						--ro
