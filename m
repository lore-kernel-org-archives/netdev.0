From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/caifcaif_dev.c: Use netdev_<level>
Date: Mon, 06 Sep 2010 18:40:38 -0700 (PDT)
Message-ID: <20100906.184038.45882158.davem@davemloft.net>
References: <1283758271.23280.73.camel@Joe-Laptop>
	<1283760489.23280.77.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjur.brandeland@stericsson.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57948
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756034Ab0IGBkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 21:40:21 -0400
In-Reply-To: <1283760489.23280.77.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 06 Sep 2010 01:08:09 -0700

> Convert pr_<level>("%s" ..., (struct netdev *)->name ...)
> to netdev_<level>((struct netdev *), ...)
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
