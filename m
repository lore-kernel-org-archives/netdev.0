From: Simon Horman <horms@verge.net.au>
Subject: Re: Kconfig warnings on latest GIT
Date: Fri, 11 May 2007 11:05:45 +0900
Message-ID: <20070511020545.GG10715@verge.net.au>
References: <200705080004.14570.ismail@pardus.org.tr> <20070508143127.38fafa3c.kim.phillips@freescale.com> <4640D988.1040504@freescale.com> <20070510051042.GA16812@verge.net.au> <46434ED0.6030808@freescale.com> <20070511012529.GC10715@verge.net.au> <Pine.LNX.4.64.0705102046400.10555@gate.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Timur Tabi <timur@freescale.com>,
	Kim Phillips <kim.phillips@freescale.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ismail =?iso-8859-1?Q?D=F6nmez?= <ismail@pardus.org.tr>,
	Michael Schmitz <schmitz@debian.org>,
	Roman Zippel <zippel@linux-m68k.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:45388 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752274AbXEKCFr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 22:05:47 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705102046400.10555@gate.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 10, 2007 at 08:47:05PM -0500, Kumar Gala wrote:
> Try this patch:

That certainly resolves the problem for me.
I'll see about doing something like that for the similar
Kconfig problems that I see.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

