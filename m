From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3 : sparse cleanup
Date: Thu, 24 Apr 2008 23:33:17 -0700 (PDT)
Message-ID: <20080424.233317.60350081.davem@davemloft.net>
References: <48117AC7.40507@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48959
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756969AbYDYGdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 02:33:17 -0400
In-Reply-To: <48117AC7.40507@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 25 Apr 2008 08:31:35 +0200

> Fix the following sparse warning :
> 
> drivers/net/tg3.c:4025:3: warning: context imbalance in 'tg3_restart_hw' 
> - unexpected unlock
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks a lot Eric.
