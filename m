From: <Matt_Domsch@Dell.com>
Subject: Linux Plumbers Conference: User-visible Network Issues Mini-Conf
Date: Fri, 17 Sep 2010 14:12:29 -0500
Message-ID: <1B9798A3396AB0429545ADFEA207931510536C7C8E@AUSX7MCPS302.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxipps301.us.dell.com ([143.166.148.223]:30735 "EHLO
	ausxipps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754374Ab0IQTMc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 15:12:32 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At the Linux Plumbers Conference [1] November 3-5, 2010 in Cambridge, MA, we have a half-day mini-conference [2] set aside to discuss "User-visible Network Issues" - challenges that users face, that could benefit from both userspace and kernel enhancements to make their lives easier.

Discussion proposals for this track are:

* Achieving Better Out-of-the-box Network Scaling 
This is a discussion of how Linux needs to scale better out-of-the-box with large I/O network devices. 
Peter Waskiewicz

* Challenges in Mobile Networking 
Challenges that we have with networking in the mobile space.
Dan Williams and Marcel Holtmann

* Data Center Bridging: Creating DCB aware networks 
Presentation will highlight the ongoing efforts for enabling data center bridging technologies in the Linux kernel to meet the requirements of applications and stacks over Ethernet. 
John Fastabend

* Network Device Naming 
Which of my NICs is eth0? 
Matt Domsch 

* Scaling techniques in the stack for servers with high connection rates 
This talk will describe some techniques for scaling front end servers. In particular, we will describe the the use of SO_REUSEPORT in scaling servers for high connection rates with a single listening port. 
Tom Herbert 

* Simplifying network configuration for VMs by harmonizing multiple Bridging, QOS, DCB and CNA implementations 
Shyam Iyer


While I'm sure the individual topics will generate great discussion, it will be vital that members of the netdev community be present to represent the kernel developers' perspectives on the problems and to help brainstorm solutions.  Most of these topics have significant kernel components to them, and without additional kernel developer participation, I fear we would just be talking to ourselves, but no real progress made.

I invite you to attend LPC, and this mini-conf in particular, and lend your expertise.  If you will be attending, which of the above topics are of most interest to you? We won't be able to cover all of these in the mini-conf, so those with the most interest  (plus mine of course!) will make the agenda.

Thanks,
Matt

[1] http://www.linuxplumbersconf.org/2010/
[2] http://www.linuxplumbersconf.org/2010/ocw/events/LPC2010MC/tracks/63

--
Matt Domsch
Technology Strategist
Dell | Office of the CTO

