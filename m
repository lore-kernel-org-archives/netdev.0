From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove INIT_RCU_HEAD() usage
Date: Tue, 16 Feb 2010 23:38:07 -0800 (PST)
Message-ID: <20100216.233807.48509000.davem@davemloft.net>
References: <20100212214138.GA5866@x200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45520
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751573Ab0BQHhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 02:37:51 -0500
In-Reply-To: <20100212214138.GA5866@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 12 Feb 2010 23:41:39 +0200

> call_rcu() will unconditionally reinitialize RCU head anyway.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied to net-next-2.6
