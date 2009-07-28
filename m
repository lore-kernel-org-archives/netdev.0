From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: Re: [net-next-2.6 PATCH 1/3] mlx4_en: Adaptive moderation policy
 change
Date: Tue, 28 Jul 2009 11:06:57 +0300
Message-ID: <4A6EB1A1.2050209@mellanox.co.il>
References: <4A631A64.50804@mellanox.co.il> <20090721.131046.124136196.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:60720 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750733AbZG1IIj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jul 2009 04:08:39 -0400
In-Reply-To: <20090721.131046.124136196.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Well Roland, after you flamed me last time for applying mlx4 patches
> without your review, I'd like to know if you're going to look at these
> three patches and also the independently submitted "mlx4: Fix double
> pci unmapping." bug fix from Yevgeny or are these changes going to
> simply rot on netdev?
> 
> They all look fine to me, but hey I remember what happened last time
> :-)
> 
Hi,
Is there an update on those patches?
I saw that the "mlx4_en: Fix double pci unmapping." patch is still not applied and it is
pretty important bug fix that should make it to 2.6.31.
As for your discussion, I send all the Ethernet related patches (mlx4_en) to Dave, and all the
low level related patches (mlx4_core) to Roland. I put the netdev list in CC in both cases.
If you guys want me to change something in the way I send the patches, just let me know,
so we could avoid situations where both (or none) of you handle those patches.

Thanks,
Yevgeny
