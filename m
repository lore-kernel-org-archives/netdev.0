From: Simon Horman <horms@verge.net.au>
Subject: Re: Kconfig warnings on latest GIT
Date: Fri, 11 May 2007 10:22:18 +0900
Message-ID: <20070511012216.GB10715@verge.net.au>
References: <200705080004.14570.ismail@pardus.org.tr> <20070508143127.38fafa3c.kim.phillips@freescale.com> <4640D988.1040504@freescale.com> <20070510051042.GA16812@verge.net.au> <1178811570.3806.18.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Timur Tabi <timur@freescale.com>,
	Kim Phillips <kim.phillips@freescale.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ismail =?iso-8859-1?Q?D=F6nmez?= <ismail@pardus.org.tr>,
	Kumar Gala <galak@kernel.crashing.org>,
	Michael Schmitz <schmitz@debian.org>,
	Roman Zippel <zippel@linux-m68k.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:45283 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754866AbXEKBWV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 21:22:21 -0400
Content-Disposition: inline
In-Reply-To: <1178811570.3806.18.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 10, 2007 at 05:39:29PM +0200, Johannes Berg wrote:
> On Thu, 2007-05-10 at 14:10 +0900, Simon Horman wrote:
> 
> > drivers/macintosh/Kconfig:112:warning: 'select' used by config symbol 'PMAC_APM_EMU' refer to undefined symbol 'SYS_SUPPORTS_APM_EMULATION'
> 
> Argh. Is that with ARCH=ppc? I keep forgetting that it still exists,
> sorry.

Actually, it was with ARCH=ia64. I have a feeling that you can get
it to show up quite easily with anything other than ARCH=powerpc.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

