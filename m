From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/17] mlx4_en: driver updates
Date: Mon, 07 Mar 2011 11:52:48 -0800 (PST)
Message-ID: <20110307.115248.189690888.davem@davemloft.net>
References: <4D74B092.5010408@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58943
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755274Ab1CGTwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 14:52:10 -0500
In-Reply-To: <4D74B092.5010408@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 7 Mar 2011 12:16:50 +0200

> This patch set presents a set of fixes, performance improvements and new features for the mlx4_core and mlx4_en modules.
> main changes are:
> - MSI-X per ring
> - Changing RX packet steering model for supported devices
> - BlueFlame support for better TX latency.
> - Adaptive moderation improvements.
> 

Please synchronize your changes with me more frequently, so that I don't
have to review so many changes at one time.
