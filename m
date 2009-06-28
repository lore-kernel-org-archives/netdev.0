From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 13627] New: Tunnel device ignores TCP/UDP
 traffic
Date: Sat, 27 Jun 2009 21:55:04 -0700 (PDT)
Message-ID: <20090627.215504.193712058.davem@davemloft.net>
References: <20090627020403.GB19639@gondor.apana.org.au>
	<20090626.192247.17381002.davem@davemloft.net>
	<4A464AC1.3070906@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, pm@debian.org
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43891
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750804AbZF1EzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2009 00:55:01 -0400
In-Reply-To: <4A464AC1.3070906@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Sat, 27 Jun 2009 18:37:21 +0200

> David Miller wrote:
>> From: Herbert Xu <herbert@gondor.apana.org.au>
>> Date: Sat, 27 Jun 2009 10:04:03 +0800
>> 
>>> Doh, I'd forgotten about transparent proxying.
>>>
>>> inet: Call skb_orphan before tproxy activates
 ...
> just a reminder, if you already queued up the original patch for
> 2.6.30-stable, that this patch has to follow then also.

Indeed, I know.
