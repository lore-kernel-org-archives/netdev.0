From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH REPOST net-next-2.6 3/4] bonding: Fix useless test: int
 > INT_MAX
Date: Fri, 28 Aug 2009 16:22:47 -0700 (PDT)
Message-ID: <20090828.162247.257033799.davem@davemloft.net>
References: <1251497115-16234-4-git-send-email-fubar@us.ibm.com>
	<20090828.154911.197007102.davem@davemloft.net>
	<23655.1251501514@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.2p.debian@free.fr
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40304
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750921AbZH1XWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 19:22:33 -0400
In-Reply-To: <23655.1251501514@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri, 28 Aug 2009 16:18:34 -0700

> 	Hmm.  Does this one work any better?

Yep, this one made it through, thanks.

> I just copied the Signed-off-by text into the From: line.

'git format-patch' and similar tools should provide the From: line for
you automatically.
