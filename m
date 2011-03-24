From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4_en: Removing HW info from ethtool -i report.
Date: Thu, 24 Mar 2011 11:48:01 -0700 (PDT)
Message-ID: <20110324.114801.52200860.davem@davemloft.net>
References: <4D8B028B.8050406@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58330
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933288Ab1CXSrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 14:47:22 -0400
In-Reply-To: <4D8B028B.8050406@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Thu, 24 Mar 2011 10:36:27 +0200

> Avoiding abuse of ethtool_drvinfo.driver field.
> HW specific info can be retrieved using lspci.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied, thanks.
