From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] mlx4_en: Adaptive moderation policy
 change
Date: Tue, 21 Jul 2009 13:10:46 -0700 (PDT)
Message-ID: <20090721.131046.124136196.davem@davemloft.net>
References: <4A631A64.50804@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57034
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752398AbZGUUKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 16:10:41 -0400
In-Reply-To: <4A631A64.50804@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Well Roland, after you flamed me last time for applying mlx4 patches
without your review, I'd like to know if you're going to look at these
three patches and also the independently submitted "mlx4: Fix double
pci unmapping." bug fix from Yevgeny or are these changes going to
simply rot on netdev?

They all look fine to me, but hey I remember what happened last time
:-)
