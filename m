From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core/utils: fix sparse warning
Date: Tue, 07 Aug 2007 18:03:02 -0700 (PDT)
Message-ID: <20070807.180302.93385236.davem@davemloft.net>
References: <1186418247.28655.82.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51117
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754896AbXHHBDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 21:03:03 -0400
In-Reply-To: <1186418247.28655.82.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 06 Aug 2007 18:37:26 +0200

> net_msg_warn is not defined because it is in net/sock.h which isn't
> included.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Applied, thanks Johannes.
