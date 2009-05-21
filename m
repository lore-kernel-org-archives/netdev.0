From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gigaset: beyond ARRAY_SIZE of iwb->data
Date: Thu, 21 May 2009 15:04:24 -0700 (PDT)
Message-ID: <20090521.150424.115610710.davem@davemloft.net>
References: <4A15BA76.6080007@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hjlipp@web.de, gigaset307x-common@lists.sourceforge.net,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56311
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754937AbZEUWEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 18:04:25 -0400
In-Reply-To: <4A15BA76.6080007@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Thu, 21 May 2009 22:32:54 +0200

> Do not go beyond ARRAY_SIZE of iwb->data
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> Sorry for the dup, the header was incorrect. This is against linux-next.

Applied to net-2.6
