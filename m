From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp/ipv6.c: use ipv6_addr_copy
Date: Thu, 22 Jan 2009 13:50:01 -0800 (PST)
Message-ID: <20090122.135001.136640302.davem@davemloft.net>
References: <1232658506.15489.63.camel@localhost>
	<4978E2B3.3010109@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, sri@us.ibm.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47670
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752631AbZAVVt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 16:49:59 -0500
In-Reply-To: <4978E2B3.3010109@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 22 Jan 2009 16:18:43 -0500

> Joe Perches wrote:
> > Signed-off-by: Joe Perches <joe@perches.com>
 ...
> ACK.  Simple enough of a cleanup.

Applied to net-next-2.6, thanks.
