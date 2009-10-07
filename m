From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: use ipv6_addr_set_v4mapped()
Date: Wed, 07 Oct 2009 13:58:33 -0700 (PDT)
Message-ID: <20091007.135833.127722444.davem@davemloft.net>
References: <4ACCB816.2000902@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57321
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934347AbZJGU6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 16:58:37 -0400
In-Reply-To: <4ACCB816.2000902@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Wed, 07 Oct 2009 11:47:34 -0400

> Might as well use the ipv6_addr_set_v4mapped() inline we created last
> year.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Also applied, thanks.
