From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] be2net: Workaround to fix a bug in Rx
 Completion processing.
Date: Wed, 30 Sep 2009 16:37:27 -0700 (PDT)
Message-ID: <20090930.163727.180617737.davem@davemloft.net>
References: <20090930090656.GA5215@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50386
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754771AbZI3XhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 19:37:08 -0400
In-Reply-To: <20090930090656.GA5215@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Wed, 30 Sep 2009 14:37:06 +0530

> vtp bit in RX completion descriptor could be wrongly set in
> some skews of BladEngine.  Ignore this  bit if vtm is not set.
> This patch is against the net-next-2.6 tree.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

This doesn't apply.

Until I start taking new feature patches, net-next-2.6 is just
going to be a stale GIT tree based upon Linus's tree at some
point in time long ago.

net-2.6 is far in front of that, and actually since this is a bug
fix you really should be sending me this patch against that.
