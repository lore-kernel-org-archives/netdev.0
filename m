From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] myri10ge: drop myri10ge_lro module parameter
Date: Mon, 25 May 2009 00:36:40 -0700 (PDT)
Message-ID: <20090525.003640.226194110.davem@davemloft.net>
References: <4A196777.9050700@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42780
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751381AbZEYHgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2009 03:36:41 -0400
In-Reply-To: <4A196777.9050700@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brice Goglin <brice@myri.com>
Date: Sun, 24 May 2009 17:27:51 +0200

> Drop the myri10ge_lro module parameter now that we have ethtool
> to enable/disable LRO in the myri10ge driver.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>

Applied to net-next-2.6
