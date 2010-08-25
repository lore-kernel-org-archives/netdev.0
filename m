From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/14] mlx4_en: Fixed incorrect unmapping on RX flow.
Date: Wed, 25 Aug 2010 02:28:59 -0700 (PDT)
Message-ID: <20100825.022859.226793571.davem@davemloft.net>
References: <4C73CCE1.6050609@mellanox.co.il>
	<20100824.150746.232758581.davem@davemloft.net>
	<E113D394D7C5DB4F8FF691FA7EE9DB443B56826877@MTLMAIL.mtl.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eugenia@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44453
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751825Ab0HYJ2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 05:28:44 -0400
In-Reply-To: <E113D394D7C5DB4F8FF691FA7EE9DB443B56826877@MTLMAIL.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Wed, 25 Aug 2010 11:55:55 +0300

> I suspect that these warnings were caused by the merge with the patch you mentioned,
> The patches I sent remove this label:

Yes that seems to be the case, my bad :-)
