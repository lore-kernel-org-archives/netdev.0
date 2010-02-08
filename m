From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 15239] New: Problem with network performance
 after a while.
Date: Mon, 08 Feb 2010 14:55:31 -0800 (PST)
Message-ID: <20100208.145531.143618406.davem@davemloft.net>
References: <bug-15239-10286@http.bugzilla.kernel.org/>
	<20100208141513.b5d0be56.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	alexander.h.duyck@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, pstaszewski@artcom.pl, stable@kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49178
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750946Ab0BHWzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 17:55:18 -0500
In-Reply-To: <20100208141513.b5d0be56.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 8 Feb 2010 14:15:13 -0800

> That would be bad.  That's a regression in 2.6.33-rc, and we've
> backported that regression into 2.6.32.x -stable.

Luckily we have a fix already. :-)
