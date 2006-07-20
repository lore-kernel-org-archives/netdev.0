From: jamal <hadi@cyberus.ca>
Subject: Re: Alternate to Ixia's ANVL test harness for tcp compliance.
Date: Thu, 20 Jul 2006 16:08:49 -0400
Message-ID: <1153426129.5273.123.camel@jzny2>
References: <1153424967.8114.450.camel@piet2.bluelane.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rajneesh Saini <rksaini@gmail.com>,
	piet at work <piet@work.piet.net>, Andi Kleen <ak@suse.de>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:29121 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1030374AbWGTUJ2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 16:09:28 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1G3epw-0004Ge-NR
	for netdev@vger.kernel.org; Thu, 20 Jul 2006 16:09:32 -0400
To: piet@bluelane.com
In-Reply-To: <1153424967.8114.450.camel@piet2.bluelane.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-20-07 at 12:49 -0700, Piet Delaney wrote:
> Hey Gang:
> 
> Both at UNM and Bluelane we have used Ixia's ANVL test harness for 
> verifying TCP protocol compliance with the RFC's. Recent additions
> to Ixia's ANVL GUI provide a ethereal like GUI. It looks really slick;
> even providing ladder diagrams for quickly viewing the big picture.
> 
> Unfortunately Ixia told me they don't have any plains to port the
> new GUI to linux. Instead they are trying to migrate Linux developers,
> us, to using Windows. Yeck!
> 
> With Ixia migrating away from Linux I was wondering if we should
> consider using an alternate test bed for TCP protocol compliance.
> 
> Do any of you use tools other than ANVL for RFC compliance while
> hacking to the tcp code?
> 

Talk to the USAGI folks. They have something similar to ANVL called TAHI
that they use to check compliance in IPV4, IPV6 and IPSEC. It should be
extendable with some effort to do TCP.

> In the unlikely event that there isn't an alternate; is there any
> interest in a netdev group effort to motivate Ixia to porting their C 
> sharp code to linux. I get the feeling that come of their developers
> would like to port the code to linux.

Create competition for them  - it is the easiest way to get them
motivated.


cheers,
jamal

