From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix rtable leak in net/ipv4/route.c
Date: Wed, 20 May 2009 17:19:43 -0700 (PDT)
Message-ID: <20090520.171943.247296889.davem@davemloft.net>
References: <4A138CFE.5070901@cosmosbay.com>
	<4A139FC4.7030309@cosmosbay.com>
	<20090520104838.GB25492@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, jarkao2@gmail.com, lav@yar.ru,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50547
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753032AbZEUATo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 20:19:44 -0400
In-Reply-To: <20090520104838.GB25492@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 20 May 2009 06:48:38 -0400

> On Wed, May 20, 2009 at 08:14:28AM +0200, Eric Dumazet wrote:
>> [PATCH] net: fix rtable leak in net/ipv4/route.c
 ...
>> Reported-and-analyzed-by: Alexander V. Lukyanov <lav@yar.ru>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> 

Also applied and queued up for -stable, thanks!
