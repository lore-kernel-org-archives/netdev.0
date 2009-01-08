From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] mlx4_en: Consider inline packets on completion
Date: Thu, 08 Jan 2009 10:57:22 -0800 (PST)
Message-ID: <20090108.105722.243554394.davem@davemloft.net>
References: <4964C472.2060906@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, rdreier@cisco.com, netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59722
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755189AbZAHS5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 13:57:21 -0500
In-Reply-To: <4964C472.2060906@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Wed, 07 Jan 2009 17:04:18 +0200

> Was trying to unmap work queue entries that had inline packets,
> so naturally weren't mapped.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
