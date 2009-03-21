From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] skb: expose and constify hash primitives
Date: Sat, 21 Mar 2009 13:39:34 -0700 (PDT)
Message-ID: <20090321.133934.96570038.davem@davemloft.net>
References: <20090319233404.6697768b@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56356
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753945AbZCUUjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 16:39:47 -0400
In-Reply-To: <20090319233404.6697768b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 19 Mar 2009 23:34:04 -0700

> 
> Some minor changes to queue hashing:
>  1. Use const on accessor functions
>  2. Export skb_tx_hash for use in drivers (see ixgbe)
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
