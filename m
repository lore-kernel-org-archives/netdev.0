From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [SCTP]: Fix err_hdr assignment in sctp_init_cause.
Date: Tue, 09 Jan 2007 14:36:28 -0800 (PST)
Message-ID: <20070109.143628.104034780.davem@davemloft.net>
References: <1168370809.24896.20.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59689
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932417AbXAIWg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 17:36:29 -0500
To: sri@us.ibm.com
In-Reply-To: <1168370809.24896.20.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Tue, 09 Jan 2007 11:26:49 -0800

> [SCTP]: Fix err_hdr assignment in sctp_init_cause.
> 
> The subh->err_hdr should point to the error header, not the data.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied, thanks Sridahr.

Do we need this for the 2.6.x -stable branches too?

Thanks again.
