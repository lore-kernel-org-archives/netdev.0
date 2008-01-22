From: David Miller <davem@davemloft.net>
Subject: Re: [IPV4] igmp sparse warnings
Date: Mon, 21 Jan 2008 17:28:40 -0800 (PST)
Message-ID: <20080121.172840.163064116.davem@davemloft.net>
References: <20080121095217.4ddbcaf8@deepthought>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42331
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754760AbYAVB2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 20:28:33 -0500
In-Reply-To: <20080121095217.4ddbcaf8@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 21 Jan 2008 09:52:17 -0800

> Partial sparse warning fix.  The other conditional locking
> is too much for sparse to handle.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
