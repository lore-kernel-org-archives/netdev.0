From: David Miller <davem@davemloft.net>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help()
 2.6.18-rc3
Date: Sun, 30 Jul 2006 21:59:07 -0700 (PDT)
Message-ID: <20060730.215907.58439803.davem@davemloft.net>
References: <44CD8415.2020403@davidcoulson.net>
	<44CD85FF.9010607@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david@davidcoulson.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:16099
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751478AbWGaE7j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 00:59:39 -0400
To: kaber@trash.net
In-Reply-To: <44CD85FF.9010607@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 31 Jul 2006 06:24:31 +0200

> This is a known problem with NAT and HW checksum and will probably get
> fixed in 2.6.19.

I would like to see this fixed for 2.6.18, no later.

Either that or disable the bug trap, but taking this route
is severely discouraged. :)



