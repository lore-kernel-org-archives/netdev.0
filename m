From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] be2net: get rid of be_get_stats()
Date: Tue, 24 Aug 2010 12:22:25 -0700 (PDT)
Message-ID: <20100824.122225.189719697.davem@davemloft.net>
References: <1282663102.2477.253.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, somnathk@serverengines.com,
	ajitk@serverengines.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42619
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755077Ab0HXTWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 15:22:07 -0400
In-Reply-To: <1282663102.2477.253.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Aug 2010 17:18:22 +0200

> drivers can avoid implementing ndo_get_stats method if using netdevice
> stats structure.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
