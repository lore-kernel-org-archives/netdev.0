From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/8] net: rps: use proto_ports_offset() to handle the
 AH message correctly
Date: Thu, 19 Aug 2010 17:16:59 -0700 (PDT)
Message-ID: <20100819.171659.68151550.davem@davemloft.net>
References: <1282107872-3546-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49310
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753050Ab0HTAQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 20:16:43 -0400
In-Reply-To: <1282107872-3546-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Wed, 18 Aug 2010 13:04:32 +0800

> The SPI isn't at the beginning of an AH message.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied.
