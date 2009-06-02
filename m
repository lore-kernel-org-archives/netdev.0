From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8] mlx4_en: Giving interface name in debug messages
Date: Tue, 02 Jun 2009 00:36:29 -0700 (PDT)
Message-ID: <20090602.003629.79232396.davem@davemloft.net>
References: <4A1A57AA.1080209@mellanox.co.il>
	<4A1B92D1.8070907@mellanox.co.il>
	<4A24C641.6060506@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48320
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751742AbZFBHg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 03:36:28 -0400
In-Reply-To: <4A24C641.6060506@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Tue, 02 Jun 2009 09:27:13 +0300

> For each debug message, the message will show interface name in case
> that the net device was registered, and PCI bus ID with port number
> if we were not registered yet. Messages that are not port/netdev specific
> stayed in the old format
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

So where are the 7 other patches of this 8 patch set?
