From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: ethtool_op_get_rx_csum() should be
 public and exported
Date: Mon, 27 Jul 2009 11:36:47 -0700 (PDT)
Message-ID: <20090727.113647.12604417.davem@davemloft.net>
References: <1248305902.1061.84.camel@w-sridhar.beaverton.ibm.com>
	<20090726.194957.162341485.davem@davemloft.net>
	<4A6D70D3.8030408@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44734
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753948AbZG0Sgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 14:36:40 -0400
In-Reply-To: <4A6D70D3.8030408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 27 Jul 2009 11:18:11 +0200

> [PATCH] net: ethtool_op_get_rx_csum() should be public and exported
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Fair enough, applied, but now you are on the hook to add at
least one user of this :-)
