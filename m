From: Piet Delaney <piet@bluelane.com>
Subject: Alternate to Ixia's ANVL test harness for tcp compliance.
Date: Thu, 20 Jul 2006 12:49:26 -0700
Message-ID: <1153424967.8114.450.camel@piet2.bluelane.com>
Reply-To: piet@bluelane.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Piet Delaney <piet@bluelane.com>,
	piet at work <piet@work.piet.net>,
	Rajneesh Saini <rksaini@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mse2fe2.mse2.exchange.ms ([66.232.26.194]:44444 "EHLO
	mse2fe2.mse2.exchange.ms") by vger.kernel.org with ESMTP
	id S1030368AbWGTTtb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 15:49:31 -0400
To: netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>,
	David Miller <davem@davemloft.net>, Andi Kleen <ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Gang:

Both at UNM and Bluelane we have used Ixia's ANVL test harness for 
verifying TCP protocol compliance with the RFC's. Recent additions
to Ixia's ANVL GUI provide a ethereal like GUI. It looks really slick;
even providing ladder diagrams for quickly viewing the big picture.

Unfortunately Ixia told me they don't have any plains to port the
new GUI to linux. Instead they are trying to migrate Linux developers,
us, to using Windows. Yeck!

With Ixia migrating away from Linux I was wondering if we should
consider using an alternate test bed for TCP protocol compliance.

Do any of you use tools other than ANVL for RFC compliance while
hacking to the tcp code?

In the unlikely event that there isn't an alternate; is there any
interest in a netdev group effort to motivate Ixia to porting their C 
sharp code to linux. I get the feeling that come of their developers
would like to port the code to linux.

-piet

-- 
Piet Delaney
BlueLane Teck
W: (408) 200-5256; piet@bluelane.com
H: (408) 243-8872; piet@piet.net


