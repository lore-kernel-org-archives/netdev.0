From: David Miller <davem@davemloft.net>
Subject: Re: [RFC SKBUFF]: Keep track of writable header len of headerless
 clones
Date: Sun, 24 Jun 2007 19:58:49 -0700 (PDT)
Message-ID: <20070624.195849.56163383.davem@davemloft.net>
References: <467E6950.4020707@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46770
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751742AbXFYC6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 22:58:30 -0400
In-Reply-To: <467E6950.4020707@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Sun, 24 Jun 2007 14:53:36 +0200

> I expect other users can see a similar performance improvement,
> packet mangling iptables targets, ipip and ip_gre come to mind ..
> 
> Comments welcome.

Patrick please give me a suitable signed-off-by line, I'd
like to apply this to net-2.6.23
