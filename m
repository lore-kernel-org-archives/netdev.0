From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [fw@deneb.enyo.de: Route cache performance under stress]
Date: Sun, 6 Apr 2003 19:20:56 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16016.25080.233350.191885@robur.slu.se>
References: <20030405165016.GA32361@outpost.ds9a.nl>
	<20030405134350.N68419@shell.cyberus.ca>
	<873ckwftal.fsf@deneb.enyo.de>
	<20030405180607.P68419@shell.cyberus.ca>
	<87n0j3ltf0.fsf@deneb.enyo.de>
	<20030406110728.G68419@shell.cyberus.ca>
	<87wui71st8.fsf@deneb.enyo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Florian Weimer <fw@deneb.enyo.de>
In-Reply-To: <87wui71st8.fsf@deneb.enyo.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Florian Weimer writes:
 > jamal <hadi@cyberus.ca> writes:
 > 
 > > cat /proc/net/rt_cache_stat
 > > Should give us a lot more info.

 You can use rtstat to read it.
 robur.slu.se:
 /pub/Linux/net-development/rt_cache_stat/rtstat.c

 It's in iproute2 package too but it seems to be an older version.

 Cheers.

						-ro
