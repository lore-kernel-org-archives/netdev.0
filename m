From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] cxgb3: convert to use netdev_for_each_addr
Date: Wed, 17 Feb 2010 16:03:31 -0800 (PST)
Message-ID: <20100217.160331.94046319.davem@davemloft.net>
References: <20100217222714.GF2635@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, divy@chelsio.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42079
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758048Ab0BRADP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 19:03:15 -0500
In-Reply-To: <20100217222714.GF2635@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 17 Feb 2010 23:27:14 +0100

> Removed whole t3_rx_mode structure and appropriate helpers cause they are no
> longer needed.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.
