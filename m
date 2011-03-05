From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Remove flowi from struct rtable.
Date: Fri, 04 Mar 2011 23:09:14 -0800 (PST)
Message-ID: <20110304.230914.112605809.davem@davemloft.net>
References: <20110304.221214.189707201.davem@davemloft.net>
	<1299308388.2758.71.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45198
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751073Ab1CEHIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 02:08:37 -0500
In-Reply-To: <1299308388.2758.71.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 05 Mar 2011 07:59:48 +0100

> Eventually we could have a helper for this, as this is done three times
> in this file. Or maybe you have further plans for ipmr ?

No immediate plans, so yes I'll make a helper, good idea.
