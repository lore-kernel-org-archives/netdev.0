From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sky2: Fix TX_MAP_PAGE misspelling
Date: Tue, 02 Feb 2010 16:00:16 -0800 (PST)
Message-ID: <20100202.160016.267972431.davem@davemloft.net>
References: <20100201101907.GA12132@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mbreuer@majjas.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45576
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755660Ab0BCAAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 19:00:03 -0500
In-Reply-To: <20100201101907.GA12132@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 1 Feb 2010 10:19:07 +0000

> Btw of the dma-debug problem reported by Michael Breuer I spotted
> a tiny misspelling in TX_MAP_PAGE definition introduced by commit
> 6b84dacadbdc3.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied.

Thank goodness hex and octal 2 are the same :-)
