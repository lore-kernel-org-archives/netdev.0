From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] WARNING: some request_irq() failures ignored in
 el2_open()
Date: Wed, 02 Sep 2009 23:10:49 -0700 (PDT)
Message-ID: <20090902.231049.224678267.davem@davemloft.net>
References: <4A9D4AD5.1010404@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41300
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754499AbZICGKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 02:10:34 -0400
In-Reply-To: <4A9D4AD5.1010404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Tue, 01 Sep 2009 18:24:53 +0200

> Request_irq() may fail in different ways, handle accordingly.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> Don't we have to do something like this? 

Looks good, applied to net-next-2.6, thanks!
