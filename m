From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4 2.6.29] cxgb3 - set hard_xmit in the netdev_ops
Date: Wed, 26 Nov 2008 15:35:35 -0800 (PST)
Message-ID: <20081126.153535.216159302.davem@davemloft.net>
References: <20081126203814.4786.93917.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44433
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752532AbYKZXff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 18:35:35 -0500
In-Reply-To: <20081126203814.4786.93917.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Wed, 26 Nov 2008 12:38:14 -0800

> From: Divy Le Ray <divy@chelsio.com>
> 
> Fix t3_eth_xmit() missing into the netdev_ops structure.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied.
