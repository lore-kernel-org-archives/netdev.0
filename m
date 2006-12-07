From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPSEC][5/7] inter address family ipsec tunnel
Date: Wed, 06 Dec 2006 23:51:04 -0800 (PST)
Message-ID: <20061206.235104.98536282.davem@davemloft.net>
References: <20061124143852.e899dbaf.kazunori@miyazawa.org>
	<20061130.164903.26534926.davem@davemloft.net>
	<20061206203540.a03dae5c.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: miika@iki.fi, Diego.Beltrami@hiit.fi, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42035
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031815AbWLGHuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 02:50:52 -0500
To: kazunori@miyazawa.org
In-Reply-To: <20061206203540.a03dae5c.kazunori@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Date: Wed, 6 Dec 2006 20:35:40 +0900

> I fixed. As mentioned in another mail, I mixed up the changes
> in my previous patch. This adds "IPv6 over IPv4 IPsec tunnel".
> The fix of extra tab is included in another mail.
> 
> Signed-off-by: Miika Komu <miika@iki.fi>
> Signed-off-by: Diego Beltrami <Diego.Beltrami@hiit.fi>
> Signed-off-by: Kazunori Miyazawa <miyazawa@linux-ipv6.org>

I have queued this patch, we can look at it more carefully and
integrate once the linkage issue in the other patch is resolved.

Thanks.
