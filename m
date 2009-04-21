From: David Miller <davem@davemloft.net>
Subject: Re: [patch 00/13] iucv / af_iucv patches for 2.6.30-rc1
Date: Tue, 21 Apr 2009 03:39:41 -0700 (PDT)
Message-ID: <20090421.033941.140196843.davem@davemloft.net>
References: <20090421103457.965299000@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com
To: ursula.braun@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59944
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753113AbZDUKjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 06:39:49 -0400
In-Reply-To: <20090421103457.965299000@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>
Date: Tue, 21 Apr 2009 12:34:57 +0200

> here is the series of iucv / af_iucv patches for the current
> development cycle.

We're not developing in 2.6.30-rcX, we're fixing bugs.

> The patches are based on top of the current net-2.6 kernel
> (2.6.30-rc1).

There is no way in the world I'm taking 13 freakin' patches
into net-2.6 from anyone at this stage in the game.

Trim your patch list down to the most critical bug fixes,
if any.  The rest must go to net-next-2.6
