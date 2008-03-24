From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] include/linux/igmp.h - remove duplicate include
Date: Sun, 23 Mar 2008 22:18:04 -0700 (PDT)
Message-ID: <20080323.221804.248467261.davem@davemloft.net>
References: <1205106940.656.103.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47635
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753911AbYCXFSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 01:18:04 -0400
In-Reply-To: <1205106940.656.103.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sun, 09 Mar 2008 16:55:40 -0700

> Removed duplicate #include <linux/skbuff.h>	
> Combined #ifdef __KERNEL__ blocks
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
