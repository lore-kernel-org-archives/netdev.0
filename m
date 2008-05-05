From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] warn when accounting an skb that already has a
 destructor
Date: Mon, 05 May 2008 00:40:17 -0700 (PDT)
Message-ID: <20080505.004017.247102504.davem@davemloft.net>
References: <1209925940.3655.17.camel@johannes.berg>
	<20080505.002006.225975612.davem@davemloft.net>
	<1209972675.3655.15.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48895
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753422AbYEEHkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 03:40:19 -0400
In-Reply-To: <1209972675.3655.15.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 05 May 2008 09:31:15 +0200

> If we decide to uninline those functions for another reason (used too
> much, code size, ...) then we can still do that.

Agreed.
