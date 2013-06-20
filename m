From: "Eric S. Raymond" <esr@thyrsus.com>
Subject: Re: Problems in bridge.8, ip-netns.8, ip-maddress.8, ip-tunnel.8,
 ip-route.8, ip-neighbour.8, ip-rule.8
Date: Thu, 20 Jun 2013 15:29:45 -0400
Message-ID: <20130620192944.GA7832@thyrsus.com>
References: <20130618051405.06917417E7@snark.thyrsus.com>
 <20130619175357.1af033aa@nehalam.linuxnetplumber.net>
Reply-To: esr@thyrsus.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-71-162-243-5.phlapa.fios.verizon.net ([71.162.243.5]:48191
	"EHLO snark.thyrsus.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965846Ab3FTT3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 15:29:50 -0400
Content-Disposition: inline
In-Reply-To: <20130619175357.1af033aa@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org>:
> All patches should be rooted at the iproute2 top level repository 

Attempting to follow your directions, I cloned iproute2 from
github. but I don't see any of the pages I'm trying to fix in there.

esr@snark:~/software/iproute2/man/man8$ ls
arpd.8    rtacct.8  tc-bfifo.8        tc-drr.8         tc-prio.8
ip.8      rtmon.8   tc-cbq.8          tc-htb.8         tc-red.8
lnstat.8  ss.8      tc-cbq-details.8  tc-pfifo.8       tc-sfq.8
routel.8  tc.8      tc-choke.8        tc-pfifo_fast.8  tc-tbf.8

Is this the right repository? If not, where do I find it?
-- 
		<a href="http://www.catb.org/~esr/">Eric S. Raymond</a>
