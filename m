From: David Miller <davem@davemloft.net>
Subject: Re: sock_get_timestamp() ktime_to_timeval returns -2?
Date: Sun, 13 Apr 2008 21:39:54 -0700 (PDT)
Message-ID: <20080413.213954.113562360.davem@davemloft.net>
References: <013101c89683$1bd00940$0a00a8c0@Andrew>
	<47F772C7.6020700@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@bramp.freeserve.co.uk, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55227
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750808AbYDNEjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 00:39:52 -0400
In-Reply-To: <47F772C7.6020700@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 05 Apr 2008 14:38:31 +0200

> [SOCK] sk_stamp: should be initialized to ktime_set(-1L, 0)
> 
> Problem spotted by Andrew Brampton
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
