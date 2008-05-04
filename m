From: David Miller <davem@davemloft.net>
Subject: Re: 24rc8: unregister_netdevice: waiting for ... to become free
Date: Sun, 04 May 2008 03:36:45 -0700 (PDT)
Message-ID: <20080504.033645.15975561.davem@davemloft.net>
References: <264300966@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, g4klx@g4klx.demon.co.uk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: devzero@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36134
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753830AbYEDKgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 06:36:46 -0400
In-Reply-To: <264300966@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: devzero@web.de
Date: Sun, 04 May 2008 11:33:12 +0200

> > Roland, does this fix your bug?
> 
> Yes! 
> With this patch i can unload the nic driver again.

Thanks for testing, I'll push this fix to Linus.
