From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix tunnels in netns after ndo_ changes
Date: Sun, 23 Nov 2008 17:26:35 -0800 (PST)
Message-ID: <20081123.172635.99135597.davem@davemloft.net>
References: <20081123134300.GA470@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54567
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751586AbYKXB0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2008 20:26:36 -0500
In-Reply-To: <20081123134300.GA470@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sun, 23 Nov 2008 16:43:00 +0300

> dev_net_set() should be the very first thing after alloc_netdev().

Applied, thanks a lot Alexey.
