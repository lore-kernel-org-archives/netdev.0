From: bert hubert <bert.hubert@netherlabs.nl>
Subject: Re: bcm43xx-softmac broken on 2.6.20-rc2
Date: Tue, 26 Dec 2006 16:45:24 +0100
Message-ID: <20061226154524.GB12583@outpost.ds9a.nl>
References: <458EA216.7000101@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Broadcom Linux <bcm43xx-dev@lists.berlios.de>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, torvalds@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpost.ds9a.nl ([213.244.168.210]:34895 "EHLO outpost.ds9a.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932684AbWLZPp0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Dec 2006 10:45:26 -0500
To: Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <458EA216.7000101@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 24, 2006 at 09:51:50AM -0600, Larry Finger wrote:
> This is a heads-up for anyone wishing to use bcm43xx-softmac on Linus's git 
> tree, which is now at
> v2.6.20-rc2. There are two serious bugs in that code. Fixes are found below.

For some reason your patch does not apply to stock 2.6.20-rc2, although I
don't see why. Applying it by hand makes things compile though, and even
fixes the problem I mentioned in my previous post:

http://www.spinics.net/lists/netdev/msg21906.html

Thanks!

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
