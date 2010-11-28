From: David Miller <davem@davemloft.net>
Subject: Re: ethoc driver changes (version 2)
Date: Sun, 28 Nov 2010 11:17:41 -0800 (PST)
Message-ID: <20101128.111741.70196550.davem@davemloft.net>
References: <1290688232-25142-1-git-send-email-jonas@southpole.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jonas@southpole.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48240
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753866Ab0K1TRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 14:17:15 -0500
In-Reply-To: <1290688232-25142-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonas Bonn <jonas@southpole.se>
Date: Thu, 25 Nov 2010 13:30:24 +0100

> This series incorporates the changes requested in the review of the original
> set.  The patch to "prevent overflow of cur_rx" has been dropped
> completely and the comments concerning the usage of division in the
> calculation of the BD entry have been incorporated into a new patch, 
> number 8 "remove division from loops"; this new patch should take care of
> the potential overflow issues that existed previously, too.

All applied, thank you Jonas.
