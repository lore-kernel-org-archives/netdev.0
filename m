From: CaT <cat@zip.com.au>
Subject: Re: Linux 2.6.39
Date: Sun, 22 May 2011 17:22:21 +1000
Message-ID: <20110522072221.GK3956@zip.com.au>
References: <BANLkTikB37AvEgh1MAFBbYvFaxsL6W11OQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nessie.weebeastie.net ([220.233.7.36]:60835 "EHLO
	bunyip.billabong.weebeastie.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751826Ab1EVHvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 03:51:14 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTikB37AvEgh1MAFBbYvFaxsL6W11OQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Um. Should my routing table be being displayed in reverse order all of
a sudden?

$ route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         192.168.1.1     0.0.0.0         UG    0      0        0 eth1
192.168.1.0     0.0.0.0         255.255.255.0   U     1      0        0 eth1

ip route list is similar. I'm sure this is going to break a script or two
(and, perhaps, a mind or two :).

-- 
  "A search of his car uncovered pornography, a homemade sex aid, women's 
  stockings and a Jack Russell terrier."
    - http://www.dailytelegraph.com.au/news/wacky/indeed/story-e6frev20-1111118083480
