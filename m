From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xfrm6: make xfrm6_tunnel_free_spi local
Date: Thu, 21 Oct 2010 03:15:35 -0700 (PDT)
Message-ID: <20101021.031535.245399797.davem@davemloft.net>
References: <20101015081559.6ede35a0@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60555
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755809Ab0JUKPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 06:15:12 -0400
In-Reply-To: <20101015081559.6ede35a0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 15 Oct 2010 08:15:59 -0700

> Function only defined and used in one file.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
