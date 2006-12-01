From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPSEC][3/7] inter address family ipsec tunnel
Date: Thu, 30 Nov 2006 16:42:03 -0800 (PST)
Message-ID: <20061130.164203.39328386.davem@davemloft.net>
References: <20061124143831.00f4e4af.kazunori@miyazawa.org>
	<20061130105426.59df2b59.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: miika@iki.fi, Diego.Beltrami@hiit.fi, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40160
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1031650AbWLAAmB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 19:42:01 -0500
To: kazunori@miyazawa.org
In-Reply-To: <20061130105426.59df2b59.kazunori@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Date: Thu, 30 Nov 2006 10:54:26 +0900

> Hello,
> 
> I found a bug in my previous patch for af_key.
> The patch breaks transport mode.
> This is a fixed version.
> 
> Signed-off-by: Miika Komu <miika@iki.fi>
> Signed-off-by: Diego Beltrami <Diego.Beltrami@hiit.fi>
> Signed-off-by: Kazunori Miyazawa <miyazawa@linux-ipv6.org>

Applied to net-2.6.20, thanks a lot.
