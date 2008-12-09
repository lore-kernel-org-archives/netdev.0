From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] hydra: fix compilation
Date: Mon, 08 Dec 2008 23:50:38 -0800 (PST)
Message-ID: <20081208.235038.16278141.davem@davemloft.net>
References: <20081209011855.GA6785@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51519
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751696AbYLIHuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 02:50:37 -0500
In-Reply-To: <20081209011855.GA6785@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 9 Dec 2008 04:18:55 +0300

> drivers/net/hydra.c:163: error: 'hydra_netdev_ops' undeclared (first use in this function)
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, thanks a lot Alexey.
