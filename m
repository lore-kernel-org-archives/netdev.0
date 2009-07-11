From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pcnet_cs: add odd location support for write_asic
 function
Date: Fri, 10 Jul 2009 20:26:09 -0700 (PDT)
Message-ID: <20090710.202609.57274545.davem@davemloft.net>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090711090213.94a771d3.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42552
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753435AbZGKD0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2009 23:26:07 -0400
In-Reply-To: <20090711090213.94a771d3.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Date: Sat, 11 Jul 2009 09:02:13 +0900

> Currently, no one passes odd location to the write_asic function.
> But this patch add odd location support for future usage of this
> feature.
> 
> 
> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

"Who" in the future will use this feature and why do they
need it?

Ideally, you should submit this patch at the same time as
the other patch which adds a need for it.
