From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e100: Fix the TX workqueue race
Date: Sat, 24 Apr 2010 20:00:11 -0700 (PDT)
Message-ID: <20100424.200011.226755248.davem@davemloft.net>
References: <20100423.163127.62645049.davem@davemloft.net>
	<20100423.163545.157549100.davem@davemloft.net>
	<20100424113629.0ad3569b@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: alan@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57289
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752161Ab0DYDAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Apr 2010 23:00:06 -0400
In-Reply-To: <20100424113629.0ad3569b@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>
Date: Sat, 24 Apr 2010 11:36:29 +0100

> Puzzling as it came from a building -next tree. Will see whats
> happened next week if I get time, but I'm afraid net stuff isn't a
> priority - in fact its disappointing that having diagnosed a bug
> months ago (which was the hard bit) and posted a test patch months
> ago the maintainers haven't fixed it.

It's disappointing to me that someone as experienced and skilled
as yourself can't generate a clean patch which is 1) against
the appropriate tree for a bug fix and 2) actually compiles.

Or is this too much to ask? :-)
