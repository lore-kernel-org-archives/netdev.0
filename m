From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: use proper kernel types
Date: Fri, 12 Feb 2010 12:30:56 -0800 (PST)
Message-ID: <20100212.123056.68554364.davem@davemloft.net>
References: <1265757677.3688.87.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52568
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757590Ab0BLUal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 15:30:41 -0500
In-Reply-To: <1265757677.3688.87.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Tue, 09 Feb 2010 18:21:17 -0500

>     xfrm: use proper kernel types
>     
>     kernel side should use uxx instead of __uxx types
>     
>     Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

Applied to net-next-2.6
