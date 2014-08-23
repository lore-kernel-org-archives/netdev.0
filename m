From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: use MDIO_DEVS[12]
Date: Fri, 22 Aug 2014 21:17:11 -0700 (PDT)
Message-ID: <20140822.211711.942794350352409227.davem@davemloft.net>
References: <1920521.UOn8o4CGAS@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57378 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179AbaHWERM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2014 00:17:12 -0400
In-Reply-To: <1920521.UOn8o4CGAS@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 22 Aug 2014 23:56:47 +0400

> The bare register numbers are used despite <uapi/linux/mdio.h> has MDIO_DEVS[12]
> #define'd for those.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied, thank you.
