From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH - net-2.6.24 0/2] Introduce and use print_ip and
 print_ipv6
Date: Tue, 25 Sep 2007 19:29:17 -0700 (PDT)
Message-ID: <20070925.192917.21908774.davem@davemloft.net>
References: <1190271211.26101.91.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com,
	akpm@linux-foundation.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57517
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754152AbXIZC3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 22:29:17 -0400
In-Reply-To: <1190271211.26101.91.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 19 Sep 2007 23:53:31 -0700

> In the same vein as print_mac, the implementations
> introduce declaration macros:

I'm going to hold on this for now, there is no universal
agreement that this is something we want to do and I'd
like to take care of getting the more certain stuff into
net-2.6.24 before "iffy" bits like this one.

Thanks.
