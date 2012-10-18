From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: Bug?  TCP shutdown behaviour when deleting local IP addresses
Date: Thu, 18 Oct 2012 12:37:45 +0200
Message-ID: <m3vce83w1y.fsf@ursa.amorsen.dk>
References: <507F38D4.102@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.ipvision.dk ([94.127.49.3]:34736 "EHLO gate2.ipvision.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754929Ab2JRKuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2012 06:50:12 -0400
In-Reply-To: <507F38D4.102@genband.com> (Chris Friesen's message of "Wed, 17
	Oct 2012 17:01:40 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen <chris.friesen@genband.com> writes:

> 7) client waits for response from server, and waits forever or until
> keepalive expires

Please don't fix that. I sometimes move my laptop from one ethernet
socket to another. During the move I lose my DHCP-assigned IP address.

I do not want to lose my SSH sessions too.


/Benny
