From: Timur Tabi <timur@freescale.com>
Subject: Re: Kconfig warnings on latest GIT
Date: Thu, 10 May 2007 21:32:24 -0500
Message-ID: <4643D5B8.8050106@freescale.com>
References: <200705080004.14570.ismail@pardus.org.tr> <20070508143127.38fafa3c.kim.phillips@freescale.com> <4640D988.1040504@freescale.com> <20070510051042.GA16812@verge.net.au> <46434ED0.6030808@freescale.com> <20070511012529.GC10715@verge.net.au> <Pine.LNX.4.64.0705102046400.10555@gate.crashing.org> <20070511020545.GG10715@verge.net.au> <Pine.LNX.4.64.0705102111570.11348@gate.crashing.org> <20070511022721.GI10715@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <galak@kernel.crashing.org>, sam@ravnborg.org,
	Kim Phillips <kim.phillips@freescale.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Ismail_D=F6nmez?= <ismail@pardus.org.tr>,
	Michael Schmitz <schmitz@debian.org>,
	Roman Zippel <zippel@linux-m68k.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:47443 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757489AbXEKCc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 22:32:57 -0400
In-Reply-To: <20070511022721.GI10715@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Horman wrote:

> I agree. I had thought a little about a kconfig fix. Though I'm
> wondering if removing the warning will lead to oodles of dangling
> symbols and invalid checks over time.

I'm pretty sure it will.  Perhaps we need to have a lint for Kconfig?

