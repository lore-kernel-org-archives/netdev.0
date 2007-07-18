From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rfkill: Make state sysfs writable
Date: Wed, 18 Jul 2007 15:38:19 -0700 (PDT)
Message-ID: <20070718.153819.94037060.davem@davemloft.net>
References: <200707181959.22520.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dtor@insightbb.com, netdev@vger.kernel.org
To: ivdoorn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34702
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759657AbXGRWiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 18:38:20 -0400
In-Reply-To: <200707181959.22520.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivo van Doorn <ivdoorn@gmail.com>
Date: Wed, 18 Jul 2007 19:59:22 +0200

> The rfkill state Sysfs attribute should be made writable,
> we already pass the argument for the store handler,
> so we only need to update the permissions flag.
> 
> Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

Applied, thanks.
