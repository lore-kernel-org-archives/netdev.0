From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] mv643xx_eth updates
Date: Thu, 19 Feb 2009 23:58:56 -0800 (PST)
Message-ID: <20090219.235856.233995387.davem@davemloft.net>
References: <20090213000615.GJ17914@xi.wantstofly.org>
	<20090215.234630.202443700.davem@davemloft.net>
	<20090219224318.GH17914@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, nico@cam.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58477
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751752AbZBTH7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 02:59:14 -0500
In-Reply-To: <20090219224318.GH17914@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Thu, 19 Feb 2009 23:43:19 +0100

> On Sun, Feb 15, 2009 at 11:46:30PM -0800, David Miller wrote:
> 
> > And furthermore, if it is worse in some cases that is
> > a bug that we should fix rather than ignore while hiding
> > behind some Kconfig option.
 ...
> What do you think?

I've already told you what I think.

Kill the kconfig option and try to help us make LRO have
less of an impact in your tests.

You can throw a ton of numbers at me again, and I'll just
say the same thing a third time.  And I'm OK with that :-)
