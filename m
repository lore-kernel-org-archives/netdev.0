From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix the fib trie iterator to work with a single
 entry routing tables
Date: Wed, 24 Jan 2007 14:42:54 -0800 (PST)
Message-ID: <20070124.144254.78492493.davem@davemloft.net>
References: <m17ivc19na.fsf@ebiederm.dsl.xmission.com>
	<17847.54018.72176.431127@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	robert.olsson@its.uu.se
To: Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42198
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932831AbXAXWnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 17:43:19 -0500
In-Reply-To: <17847.54018.72176.431127@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Olsson <Robert.Olsson@data.slu.se>
Date: Wed, 24 Jan 2007 22:43:30 +0100

> Yes the case when the trie is just a single leaf got wrong with the
> iterator and your patchs cures it. I think we have a similar problem
> with /proc/net/fib_trie

I'm happy to review a fix for that :-)

> Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

Patch applied, thanks everyone.
