From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/3] myri10ge updates for 2.6.28
Date: Mon, 29 Sep 2008 03:30:57 +0200
Message-ID: <48E02FD1.2010502@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1880 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752463AbYI2Baf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Sep 2008 21:30:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jeff and Dave or whoever is not on a trip :)

Here's the multiqueue TX patch for myri10ge again. And it is followed by
2 patches splitting the huge myri10ge.c into pieces (no functional
changes at all there). It's my first time sending a "git rename" patch,
I hope I did well :)

Please apply for 2.6.28.
thanks,
Brice

PS: These patches are against Dave's net-next tree. So, if you get yet
another strange conflict, I'd like to see the actual conflict. I still
don't understand what could have conflicted in the previous submission,
it did apply fine as well here :/

