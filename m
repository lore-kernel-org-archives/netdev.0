From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/9 V2] mlx4_en: Multiqueue support
Date: Tue, 30 Dec 2008 11:54:47 -0800 (PST)
Message-ID: <20081230.115447.255893843.davem@davemloft.net>
References: <49589EF5.8070800@mellanox.co.il>
	<20081229.184109.77843771.davem@davemloft.net>
	<495A5262.50100@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, rdreier@cisco.com, netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37108
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752069AbYL3Tyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2008 14:54:44 -0500
In-Reply-To: <495A5262.50100@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Tue, 30 Dec 2008 18:54:58 +0200

> The generic hash function (simple_tx_hash) doesn't consider Vlan
> priority when making the hash.

Then fix it to take VLAN into account.
