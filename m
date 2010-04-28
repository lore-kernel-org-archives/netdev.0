From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/2] netfilter: xtables: inclusion of xt_SYSRQ
Date: Wed, 28 Apr 2010 17:03:00 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1004281701220.9518@obet.zrqbmnf.qr>
References: <1271845618-28569-1-git-send-email-jengelh@medozas.de> <1271845618-28569-2-git-send-email-jengelh@medozas.de> <4BCEF6B4.8090105@trash.net> <alpine.LSU.2.01.1004211506280.10840@obet.zrqbmnf.qr> <4BCEFACC.7020804@trash.net>
 <alpine.LSU.2.01.1004211533410.21020@obet.zrqbmnf.qr> <4BD84992.5030909@oracle.com> <4BD84C23.2000301@oracle.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: John Haxby <john.haxby@oracle.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4BD84C23.2000301@oracle.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2010-04-28 16:54, John Haxby wrote:
>
> use-case I see -- the one I see is where the sys admins used to have a "crash
> trolley" which was a console and PS/2 keyboard which they could plug into a
> machine to get some information, but as many rack machines no longer have
> anything PS/2 and USB hot plug is unlikely to work on a sick machine

Oh I can tell you stories... sometimes it's so dead in the water that
the console unblanking would not work any more, rendering even any PS/2
useless. Stupid southbridge chipsets blowing up DMA :-)
