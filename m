From: David Miller <davem@davemloft.net>
Subject: Re: Allowing more than 64k connections and heavily optimize
 bind(0) time.
Date: Sat, 10 Jan 2009 23:20:19 -0800 (PST)
Message-ID: <20090110.232019.98466627.davem@davemloft.net>
References: <20081224190926.GA3244@ioremap.net>
	<20081225212928.GA12038@ioremap.net>
	<20090110105931.GB358@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57256
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751114AbZAKHUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 02:20:19 -0500
In-Reply-To: <20090110105931.GB358@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Sat, 10 Jan 2009 13:59:31 +0300

> Ping :)
> 
> I'm getting out from the vacations tomorrow and will try to more
> extensively test the patch (QA group found a bug in ipv6 side, but that
> was with the .24 backported patch, current one does not have that codepath
> iirc). But I would like to know if this worth it.

I'll look at it at some point but it won't make this merge window,
sorry.
