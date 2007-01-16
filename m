From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] [SCTP]: Correctly handle unexpected INIT-ACK chunk.
Date: Mon, 15 Jan 2007 19:17:56 -0800 (PST)
Message-ID: <20070115.191756.78712820.davem@davemloft.net>
References: <1168544489.22592.20.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52691
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751100AbXAPDRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 22:17:55 -0500
To: sri@us.ibm.com
In-Reply-To: <1168544489.22592.20.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Thu, 11 Jan 2007 11:41:29 -0800

> [SCTP]: Correctly handle unexpected INIT-ACK chunk.
> 
> Consider the chunk as Out-of-the-Blue if we don't have
> an endpoint.  Otherwise discard it as before.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied, thanks.
