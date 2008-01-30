From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 'rndis' 2008-01-29
Date: Tue, 29 Jan 2008 21:26:00 -0800 (PST)
Message-ID: <20080129.212600.83713911.davem@davemloft.net>
References: <20080129212813.GB3180@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43761
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753425AbYA3FZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 00:25:41 -0500
In-Reply-To: <20080129212813.GB3180@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 29 Jan 2008 16:28:13 -0500

> Dave,
> 
> RNDIS is a de facto standard from Microsoft for USB networking devices.
> We already have support for ethernet devices, but wireless devices exist
> as well.  This series applies some fixes to the current ethernet RNDIS
> stuff to co-exist with wireless and adds a wireless RNDIS driver.  I
> would like to see it in 2.6.25.

Pulled and pushed out to net-2.6, thanks John.

I'm going to review these bits a little bit (as well as the
other merge you just made) before pushing it all out to
Linus.

Thanks!
