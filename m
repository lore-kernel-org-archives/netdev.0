From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dscc4: Undefined signed int shift
Date: Sat, 13 Feb 2016 06:10:54 -0500 (EST)
Message-ID: <20160213.061054.267616558308643316.davem@davemloft.net>
References: <20160206014624.GA20990@thinkpad.swarthmore.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com
To: mmcco@mykolab.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48330 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbcBMLK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Feb 2016 06:10:57 -0500
In-Reply-To: <20160206014624.GA20990@thinkpad.swarthmore.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael McConville <mmcco@mykolab.com>
Date: Fri, 5 Feb 2016 20:46:25 -0500

> My analysis in the below mail applies, although the second part is
> unnecessary because i isn't used in arithmetic operations here:
> 
> https://marc.info/?l=openbsd-tech&m=145377854103866&w=2
> 
> Thanks for your time.
> 
> Signed-off-by: Michael McConville <mmcco@mykolab.com>

Applied, thanks.
