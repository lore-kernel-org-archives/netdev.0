From: "Eric S. Raymond" <esr@thyrsus.com>
Subject: Re: Problems in bridge.8, ip-netns.8, ip-maddress.8, ip-tunnel.8,
 ip-route.8, ip-neighbour.8, ip-rule.8
Date: Fri, 21 Jun 2013 00:22:17 -0400
Message-ID: <20130621042217.GA11730@thyrsus.com>
References: <20130618051405.06917417E7@snark.thyrsus.com>
 <20130619175357.1af033aa@nehalam.linuxnetplumber.net>
 <20130620192944.GA7832@thyrsus.com>
 <20130620213536.GI2124@breakpoint.cc>
Reply-To: esr@thyrsus.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-71-162-243-5.phlapa.fios.verizon.net ([71.162.243.5]:53769
	"EHLO snark.thyrsus.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161172Ab3FUEWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 00:22:23 -0400
Content-Disposition: inline
In-Reply-To: <20130620213536.GI2124@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Westphal <fw@strlen.de>:
> Eric S. Raymond <esr@thyrsus.com> wrote:
> > Is this the right repository? If not, where do I find it?
> 
> git clone git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

Thank you.  I am preparing a full set of git patches against that
repository.  The immediate effect will be to allow its pages to lift
to XML-DocBook cleanly via doclifter, creating an option to generate
much higher quality HTML than you can get from a non-structural, 
presentation-level translation.

The iproute2 pages are actually about the largest group of problem
pages left in a stock Ubuntu distribution, at least since I finally
cleaned up the last of the X manual pages a few days ago.
-- 
		<a href="http://www.catb.org/~esr/">Eric S. Raymond</a>
