From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] myri10ge: optimize 4k-boundary check when stocking rx
 pages
Date: Fri, 26 Feb 2010 04:19:38 -0800 (PST)
Message-ID: <20100226.041938.113281036.davem@davemloft.net>
References: <4B85A407.5050800@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48542
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935934Ab0BZMTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 07:19:20 -0500
In-Reply-To: <4B85A407.5050800@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brice Goglin <brice@myri.com>
Date: Wed, 24 Feb 2010 23:11:19 +0100

> Small optimization to the code which checks to see if we'd cross
> a 4K boundary when stocking RX ring.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> Signed-off-by: Andrew Gallatin <gallatin@myri.com>
> Signed-off-by: Guillaume Morin <guillaume@morinfr.org>

Applied.
