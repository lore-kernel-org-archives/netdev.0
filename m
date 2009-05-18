From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] bc47xx : export ssb_watchdog_timer_set
Date: Mon, 18 May 2009 18:41:28 -0400
Message-ID: <20090518224128.GA11912@tuxdriver.com>
References: <4A11DCBF.9000700@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org, Michael Buesch <mb@bu3sch.de>,
	netdev@vger.kernel.org
To: matthieu castet <castet.matthieu@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52012 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754280AbZERWpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 18:45:15 -0400
Content-Disposition: inline
In-Reply-To: <4A11DCBF.9000700@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 12:10:07AM +0200, matthieu castet wrote:
> Hi,
>
> this patch export ssb_watchdog_timer_set to allow to use it in a Linux  
> watchdog driver.
>
>
> Signed-off-by: Matthieu CASTET <castet.matthieu@free.fr>

What is the merge path for ssb nowadays?  I used to take these patches
(and I'm still happy to do so), but maybe Ralf is (or should be)
taking them now?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
