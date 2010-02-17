From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use kasprintf() for socket cache names
Date: Wed, 17 Feb 2010 13:39:15 -0800 (PST)
Message-ID: <20100217.133915.12332482.davem@davemloft.net>
References: <20100217193411.GC5256@x200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44234
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757156Ab0BQVjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 16:39:00 -0500
In-Reply-To: <20100217193411.GC5256@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Wed, 17 Feb 2010 21:34:12 +0200

> kasprintf() makes code smaller.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
