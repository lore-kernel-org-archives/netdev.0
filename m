From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dmascc: fix incomplete conversion to network_device_ops
Date: Sat, 28 Mar 2009 23:40:12 -0700 (PDT)
Message-ID: <20090328.234012.220512059.davem@davemloft.net>
References: <20090329014224.GA23405@orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: a.beregalov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59308
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751708AbZC2GkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 02:40:24 -0400
In-Reply-To: <20090329014224.GA23405@orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Beregalov <a.beregalov@gmail.com>
Date: Sun, 29 Mar 2009 05:42:24 +0400

> drivers/net/hamradio/dmascc.c:587: error: 'struct net_device' has no
> member named 'set_mac_address'
> 
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>

Applied, thanks Alexander.
