From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: CONFIG_NET_NS reduction
Date: Wed, 02 Jun 2010 05:17:41 -0700 (PDT)
Message-ID: <20100602.051741.45151765.davem@davemloft.net>
References: <1275411079.2738.231.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52601
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751616Ab0FBMRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 08:17:31 -0400
In-Reply-To: <1275411079.2738.231.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 01 Jun 2010 18:51:19 +0200

> Use read_pnet() and write_pnet() to reduce number of ifdef CONFIG_NET_NS
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
