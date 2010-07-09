From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] sfc: Remove unused field left from
 mis-merge
Date: Thu, 08 Jul 2010 23:47:03 -0700 (PDT)
Message-ID: <20100708.234703.191389052.davem@davemloft.net>
References: <1278632192.16013.309.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35831
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752940Ab0GIGqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:46:49 -0400
In-Reply-To: <1278632192.16013.309.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 09 Jul 2010 00:36:32 +0100

> Commit eedc765ca4b19a41cf0b921a492ac08d640060d1 merged changes from
> net-2.6 that added and then removed efx_nic::port_num, which was also
> added in net-next-2.6.  The end result should be that it is removed,
> since it is now unused.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
