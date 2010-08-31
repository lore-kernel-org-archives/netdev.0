From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] gro: unexport tcp4_gro_receive and
 tcp4_gro_complete
Date: Tue, 31 Aug 2010 13:33:43 -0700 (PDT)
Message-ID: <20100831.133343.124066010.davem@davemloft.net>
References: <1283286227.2198.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51110
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753848Ab0HaUd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 16:33:26 -0400
In-Reply-To: <1283286227.2198.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 31 Aug 2010 22:23:47 +0200

> tcp4_gro_receive() and tcp4_gro_complete() dont need to be exported.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks good, I'll apply this.
