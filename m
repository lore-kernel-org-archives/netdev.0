From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ftmac100: fix scheduling while atomic during
 PHY link status change
Date: Fri, 29 Apr 2011 12:42:16 -0700 (PDT)
Message-ID: <20110429.124216.35028812.davem@davemloft.net>
References: <BANLkTi=gcFB4mbmWKu4neep77Jp8R4HWGQ@mail.gmail.com>
	<BANLkTinB1FiHYX1KoO90UepmhQdXZs0eEg@mail.gmail.com>
	<1304012478.3715.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ratbert.chuang@gmail.com, ratbert@faraday-tech.com,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: adam.jaremko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49935
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754397Ab1D2Tmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 15:42:49 -0400
In-Reply-To: <1304012478.3715.5.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adam Jaremko <adam.jaremko@gmail.com>
Date: Thu, 28 Apr 2011 13:41:18 -0400

> I think I've sorted my mail client preferences and all should be well now.
> 
> Signed-off-by: Adam Jaremko <adam.jaremko@gmail.com>
> Acked-by: Po-Yu Chuang <ratbert@faraday-tech.com>

This is better, yes, applied.
