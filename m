From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: Linux Plumbers Conference: User-visible Network Issues Mini-Conf
Date: Fri, 15 Oct 2010 14:50:44 -0500
Message-ID: <20101015195044.GA4416@auslistsprd01.us.dell.com>
References: <1B9798A3396AB0429545ADFEA207931510536C7C8E@AUSX7MCPS302.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:25519 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756557Ab0JOTup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 15:50:45 -0400
Content-Disposition: inline
In-Reply-To: <1B9798A3396AB0429545ADFEA207931510536C7C8E@AUSX7MCPS302.AMER.DELL.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At the Linux Plumbers Conference [1] November 3-5, 2010 in Cambridge,
MA, we have a half-day mini-conference [2] set aside on Thursday
morning (so as to follow immediately, but not conflict with netconf)
to discuss "User-visible Network Issues" - challenges that users face,
that could benefit from both userspace and kernel enhancements to make
their lives easier.

Accepted topics are:

* Challenges in Mobile Networking 
Challenges that we have with networking in the mobile space.
Led by Dan Williams

* Network Device Naming 
Which of my NICs is eth0? 
Led by Matt Domsch 
 
* Scaling techniques in the stack for servers with high connection rates 
This talk will describe some techniques for scaling front end
servers. In particular, we will describe the the use of SO_REUSEPORT
in scaling servers for high connection rates with a single listening
port.
Led by Ying Cai

* Simplifying network configuration for VMs by harmonizing multiple Bridging, QOS, DCB and CNA implementations 
Led by Shyam Iyer

While I'm sure the individual topics will generate great discussion,
it will be vital that members of the netdev community be present to
represent the kernel developers' perspectives on the problems and to
help brainstorm solutions.  Most of these topics have significant
kernel components to them, and without additional kernel developer
participation, I fear we would just be talking to ourselves, but no
real progress made.  I invite you to attend LPC, and this
mini-conf in particular, and lend your expertise.

If you would attend LPC, except that the conference fee is a burden,
please let me know.  I have at least one pass available for mini-conf
participants.

Thanks,
Matt

[1] http://www.linuxplumbersconf.org/2010/
[2] http://www.linuxplumbersconf.org/2010/ocw/events/LPC2010MC/tracks/63

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
