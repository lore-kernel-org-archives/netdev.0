From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/10] cxgb4vf: a number of bug fixes and minor cleanup
Date: Thu, 11 Nov 2010 09:33:15 -0800 (PST)
Message-ID: <20101111.093315.183049721.davem@davemloft.net>
References: <450C6E98-D0D9-42A6-9F15-4DB98647DB04@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leedom@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35574
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753944Ab0KKRcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 12:32:50 -0500
In-Reply-To: <450C6E98-D0D9-42A6-9F15-4DB98647DB04@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Leedom <leedom@chelsio.com>
Date: Wed, 10 Nov 2010 18:01:33 -0800

> The following patch set includes a number of bug fixes and some
> minor cleanup for the cxgb4vf network driver.  If there are any
> problems with formatting, etc. of the patch set please just reject
> the patch set and kick my butt ― I'm still a novice at putting these
> together!

This is a mix of bug fixes (which would be appropriate for net-2.6)
and also changes like cleanups and minor feature adds which are not
appropriate in net-2.6

Please split them up.

I'd suggest sending out only the real bug fixes so I can quickly get
them into net-2.6, and then later you can submit the cleanups and
feature-adds realtive to the net-2.6 stuff.
