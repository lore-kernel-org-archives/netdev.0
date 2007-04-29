From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][XFRM] export SPD info
Date: Sat, 28 Apr 2007 21:21:05 -0700 (PDT)
Message-ID: <20070428.212105.15263895.davem@davemloft.net>
References: <1177681421.4059.2.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39546
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754561AbXD2EUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2007 00:20:55 -0400
In-Reply-To: <1177681421.4059.2.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Fri, 27 Apr 2007 09:43:41 -0400

> [XFRM] Export SPD info
> 
> With this patch you can use iproute2 in user space to efficiently
> see how many policies exist in different directions.
> 
> Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

I've applied this.  Please send me something relative when
you decide how to handle the filtering situation as we've
been discussing.

Thanks.
