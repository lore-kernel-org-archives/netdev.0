From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Fri, 7 Jan 2005 20:18:56 +0100
Message-ID: <16862.57504.383176.640058@robur.slu.se>
References: <200501031455.26980.jeremy.guthrie@berbee.com>
	<200501061618.24465.jeremy.guthrie@berbee.com>
	<16861.48463.770166.352726@robur.slu.se>
	<200501071017.31751.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501071017.31751.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:

 > Did my second email w/ the lnstat data not make it?

 I see most zeroes

 > >  cat /proc/net/softnet_stat
 > total    droppped tsquz    Throttl  FR_hit   FR_succe FR_defer FR_def_o 
 >  cpu_coll 
 > > 9ba490f3 00000000 01281572 00000000 00000000 00000000 00000000 00000000
 > > 002562c2 9939268d 00000000 010e42e9 00000000 00000000 00000000 00000000 
 > > 00000000 0028fe72

 > Why do these drops not show up in the interface drop?

 These are drops in the network stack not in the devices.


					     --ro
