From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] net:use help function of
 skb_checksum_start_offset to calculate offset
Date: Thu, 28 Apr 2011 13:29:45 -0700 (PDT)
Message-ID: <20110428.132945.260072811.davem@davemloft.net>
References: <4DB1617D.30600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cmetcalf@tilera.com
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36248
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751171Ab1D1UaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 16:30:18 -0400
In-Reply-To: <4DB1617D.30600@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Fri, 22 Apr 2011 19:07:41 +0800

> Although these are equivalent, but the skb_checksum_start_offset() is more readable.
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Applied.
