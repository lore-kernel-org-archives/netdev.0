From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fec: fix clk handling for Coldfire.
Date: Sun, 17 Jun 2012 02:00:01 -0700 (PDT)
Message-ID: <20120617.020001.1114007088096967861.davem@davemloft.net>
References: <201206170000.48076.sfking@fdwdc.com>
	<20120617.010849.1446855262442120268.davem@davemloft.net>
	<201206170121.18807.sfking@fdwdc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sfking@fdwdc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60969 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752715Ab2FQJAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2012 05:00:03 -0400
In-Reply-To: <201206170121.18807.sfking@fdwdc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steven King <sfking@fdwdc.com>
Date: Sun, 17 Jun 2012 01:21:18 -0700

> On Sunday 17 June 2012 1:08:49 am David Miller wrote:
>> Sorry, I'm not going to allow you to crap up this driver with
>> ifdefs.  Find a way to fix it without that.
> 
> Well, then how about then revert the commit and have the imx folks
> do whatever they need to do without breaking things for Coldfire?

Read what I said, you have the time to fix the problem cleanly.
It's not like there's a kernel release tomorrow.
