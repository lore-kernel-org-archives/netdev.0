From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4_en: Restoring RX buffer pointer in case of failure
Date: Thu, 07 Apr 2011 20:36:37 -0700 (PDT)
Message-ID: <20110407.203637.59674660.davem@davemloft.net>
References: <4D9D8319.4030208@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47462
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757443Ab1DHDhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 23:37:14 -0400
In-Reply-To: <4D9D8319.4030208@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Thu, 7 Apr 2011 12:25:45 +0300

> 
> If not done, second attempt to open the RX ring would cause memory corruption.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
