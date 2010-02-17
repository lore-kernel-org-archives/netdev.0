From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/4] be2net: a mini optimization in
 rx_compl_process() code
Date: Wed, 17 Feb 2010 13:49:55 -0800 (PST)
Message-ID: <20100217.134955.216934693.davem@davemloft.net>
References: <20100217113422.GA19674@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59755
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757420Ab0BQVtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 16:49:40 -0500
In-Reply-To: <20100217113422.GA19674@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Wed, 17 Feb 2010 17:04:22 +0530

> Introduce unlikely() for skb alloc failure and vlanf checks...
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
