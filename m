From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c59x: Get rid of "Trying to free already-free IRQ"
Date: Thu, 24 Sep 2009 15:47:42 -0700 (PDT)
Message-ID: <20090924.154742.171195189.davem@davemloft.net>
References: <20090924183152.GA30254@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rjw@sisk.pl, linux-pm@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48668
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751369AbZIXWrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 18:47:23 -0400
In-Reply-To: <20090924183152.GA30254@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Thu, 24 Sep 2009 22:31:52 +0400

> Following trace pops up if we try to suspend with 3c59x ethernet NIC
> brought down:
 ...
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied.

