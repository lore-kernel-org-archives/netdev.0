From: Timur Tabi <timur@freescale.com>
Subject: Re: Kconfig warnings on latest GIT
Date: Fri, 11 May 2007 07:38:56 -0500
Message-ID: <464463E0.1020602@freescale.com>
References: <200705080004.14570.ismail@pardus.org.tr> <20070508143127.38fafa3c.kim.phillips@freescale.com> <4640D988.1040504@freescale.com> <20070510051042.GA16812@verge.net.au> <46434ED0.6030808@freescale.com> <20070511012529.GC10715@verge.net.au> <Pine.LNX.4.64.0705102046400.10555@gate.crashing.org> <20070511074337.GA3048@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Kumar Gala <galak@kernel.crashing.org>,
	Simon Horman <horms@verge.net.au>,
	Timur Tabi <timur@freescale.com>,
	Kim Phillips <kim.phillips@freescale.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Ismail_D=F6nmez?= <ismail@pardus.org.tr>,
	Michael Schmitz <schmitz@debian.org>,
	Roman Zippel <zippel@linux-m68k.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:48694 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756799AbXEKMjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 08:39:31 -0400
In-Reply-To: <20070511074337.GA3048@flint.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Russell King wrote:

> You might also want to fix the other stupidity with this.  See my message
> on this very subject ("select is evil: another reason" from May 9th on lkml.)

I submitted a patch yesterday which includes both fixes.  Apparently, it's already in the -mm tree.
