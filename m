From: David Miller <davem@davemloft.net>
Subject: Re: shutdown(2) does not fully shut down socket any more
Date: Fri, 08 Apr 2011 15:31:30 -0700 (PDT)
Message-ID: <20110408.153130.226769035.davem@davemloft.net>
References: <20110408221046.GW4050@outflux.net>
	<20110408.152427.193714809.davem@davemloft.net>
	<20110408223004.GY4050@outflux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kees.cook@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51951
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754291Ab1DHWcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 18:32:07 -0400
In-Reply-To: <20110408223004.GY4050@outflux.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees Cook <kees.cook@canonical.com>
Date: Fri, 8 Apr 2011 15:30:04 -0700

> Ah! Thanks, I didn't noticed that; I saw no activity on the bugzilla entry,
> so I thought it hadn't been seen yet.

We bascially do not use kernel.org bugzilla for bug tracking, all
work and discussions occur only here on the netdev list.

So what Stephen Hemminger, Andrew Morton, and others do is simply
forward the bug reports here to the list so we can work on them.
