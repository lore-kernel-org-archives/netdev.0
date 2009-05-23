From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Sat, 23 May 2009 18:45:00 +0200
Message-ID: <200905231845.00585.mb@bu3sch.de>
References: <200903041828.49972.m.bueker@berlin.de> <1243090308.4217.6.camel@obelisk.thedillows.org> <4A182066.9030201@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Dillow <dave@thedillows.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?iso-8859-1?q?B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michael Riepe <michael.riepe@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:55660 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752993AbZEWQpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 May 2009 12:45:44 -0400
In-Reply-To: <4A182066.9030201@googlemail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 23 May 2009 18:12:22 Michael Riepe wrote:

> CPU 0+2:  0.0-60.0 sec  4.65 GBytes    665 Mbits/sec
> CPU 1+3:  0.0-60.0 sec  6.43 GBytes    920 Mbits/sec
> 
> That's quite a difference, isn't it?
> 
> Now I wonder what CPU 0 is doing...

Is CPU0 the only one servicing interrupts?

-- 
Greetings, Michael.
