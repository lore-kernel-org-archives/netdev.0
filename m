From: David Miller <davem@davemloft.net>
Subject: Re: [BRIDGE] Unaligned access on IA64 when comparing ethernet
 addresses
Date: Tue, 17 Apr 2007 14:27:42 -0700 (PDT)
Message-ID: <20070417.142742.112621559.davem@davemloft.net>
References: <20070417133723.00031f82@mini>
	<20070417.140941.41631883.davem@davemloft.net>
	<46253B14.8030401@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, xemul@sw.ru,
	netdev@vger.kernel.org, bridge@lists.osdl.org, devel@openvz.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44341
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751783AbXDQV1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 17:27:40 -0400
In-Reply-To: <46253B14.8030401@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 17 Apr 2007 23:24:36 +0200

> I suspect you missed part of Stephen patch :
> 
> (maybe some mailer problem...)

My bad, sorry :(

I pushed the other version of the fix to Linus just now.
I'll put Stephen's version in if he sends me a fixup relative
to that.

Sorry again.

