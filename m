From: Michael Buesch <mb@bu3sch.de>
Subject: Re: 2.6.27.19 + 28.7: network timeouts for r8169 and 8139too
Date: Mon, 11 May 2009 22:48:44 +0200
Message-ID: <200905112248.44868.mb@bu3sch.de>
References: <200903041828.49972.m.bueker@berlin.de> <4A06D8D2.4010505@googlemail.com> <1242001754.4093.12.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Riepe <michael.riepe@googlemail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?utf-8?q?B=C3=BCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:47565 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752295AbZEKUt4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2009 16:49:56 -0400
In-Reply-To: <1242001754.4093.12.camel@obelisk.thedillows.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 11 May 2009 02:29:14 David Dillow wrote:
> > Kernel: 2.6.29.2 (x86_64)
> > Board: Intel D945GCLF2
> > BIOS version: LF94510J.86A.0099.2008.0731.0303
> 
> I'm not sure this is tied to the chip. 

Yeah maybe other chips are affected as well.
I just want to note that my failing chip/board is an Intel D945GCLF2 board
with onboard G-LAN, too.

The device XID is: XID 3c4000c0
(see kernel log)

Somebody else (I think it was Rui Santos) already reported a failing chip with that XID, too.

-- 
Greetings, Michael.
