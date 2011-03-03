From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3 v2] eql: Convert printks to pr_<level> and
 netdev_<level>
Date: Thu, 03 Mar 2011 13:30:43 -0800 (PST)
Message-ID: <20110303.133043.233687494.davem@davemloft.net>
References: <20110303.122153.70207563.davem@davemloft.net>
	<20110303.125951.200370524.davem@davemloft.net>
	<1299186492.4338.166.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54215
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758263Ab1CCVaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 16:30:06 -0500
In-Reply-To: <1299186492.4338.166.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Thu, 03 Mar 2011 13:08:12 -0800

> Add pr_fmt.
> 
> Removed trailing "\n" from version,
> add back via pr_info("%s\n", version);
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks.

> Joined of a fixed string with an __initconst string.

Aha, I see.
