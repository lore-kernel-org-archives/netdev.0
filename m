From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/9] mlx4_en: Added "set_ringparam" Ethtool interface
 implementation
Date: Thu, 25 Dec 2008 18:22:19 -0800 (PST)
Message-ID: <20081225.182219.268310314.davem@davemloft.net>
References: <494F657C.2080100@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, rdreier@cisco.com, netdev@vger.kernel.org,
	general@lists.openfabrics.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45247
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752252AbYLZCWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 21:22:16 -0500
In-Reply-To: <494F657C.2080100@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 22 Dec 2008 12:01:32 +0200

> Now using Ethtool to determine ring sizes, removed the module parameters
> that controlled those values.
> Modifying ring size requires restart of the interface.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Also doesn't apply because 4 and 7 didn't.
