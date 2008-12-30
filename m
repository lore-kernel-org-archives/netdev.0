From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/9 V2] mlx4_en: Added "set_ringparam" Ethtool
 interface implementation
Date: Mon, 29 Dec 2008 18:39:26 -0800 (PST)
Message-ID: <20081229.183926.03949599.davem@davemloft.net>
References: <49589EF2.5020607@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, rdreier@cisco.com, netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41816
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752178AbYL3CjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2008 21:39:23 -0500
In-Reply-To: <49589EF2.5020607@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 29 Dec 2008 11:57:06 +0200

> Now using Ethtool to determine ring sizes, removed the module parameters
> that controlled those values.
> Modifying ring size requires restart of the interface.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
