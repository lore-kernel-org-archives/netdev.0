From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: shy netns_ok check
Date: Wed, 12 Nov 2008 23:24:13 -0800 (PST)
Message-ID: <20081112.232413.169243333.davem@davemloft.net>
References: <20081112001509.GA2749@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, den@openvz.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36439
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751261AbYKMHYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 02:24:13 -0500
In-Reply-To: <20081112001509.GA2749@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Wed, 12 Nov 2008 03:15:09 +0300

> Sigh...
> 
> Failure to pass netns_ok check is SILENT, except some MIB counted is
> incremented somewhere.
> 
> And adding "netns_ok = 1" (after long head-scratching session) is usually
> the last step in making some protocol netns-ready...
> 
> Please, apply.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, thanks Alexey.
