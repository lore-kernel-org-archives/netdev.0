From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] axnet_cs: fix phy_id detection for bogus Asix chip.
Date: Mon, 06 Apr 2009 17:42:59 -0700 (PDT)
Message-ID: <20090406.174259.231533032.davem@davemloft.net>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46978
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751951AbZDGAnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 20:43:09 -0400
In-Reply-To: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Date: Sun, 5 Apr 2009 09:49:07 +0900

> axnet_cs:
> 
> (1) Some Asix phy return bogus value except 0 or 0xffff.
>     Skip this phy_id.
> 
> (2) Some Asix chip need to set "select Internal PHY" bit
>     at AX88190_init.
> 
> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

Applied.
