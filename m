From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : loopback driver can use loopback_dev integrated
 net_device_stats
Date: Tue, 10 Apr 2007 13:26:00 -0700 (PDT)
Message-ID: <20070410.132600.31447268.davem@davemloft.net>
References: <20070410192912.b60e86bf.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39139
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030565AbXDJUZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 16:25:59 -0400
In-Reply-To: <20070410192912.b60e86bf.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 10 Apr 2007 19:29:12 +0200

> Hi David
> 
> Please find this patch against net-2.6.22
> 
> Thank you
> 
> [PATCH] NET : loopback driver can use loopback_dev integrated net_device_stats
> 
> Rusty added a new 'stats' field to struct net_device.
> 
> loopback driver can use it instead of declaring another struct net_device_stats
> This saves some memory.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
