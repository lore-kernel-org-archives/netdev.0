From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fec: fix clk handling for Coldfire.
Date: Sun, 17 Jun 2012 01:08:49 -0700 (PDT)
Message-ID: <20120617.010849.1446855262442120268.davem@davemloft.net>
References: <201206170000.48076.sfking@fdwdc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sfking@fdwdc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60740 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533Ab2FQIIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2012 04:08:50 -0400
In-Reply-To: <201206170000.48076.sfking@fdwdc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sorry, I'm not going to allow you to crap up this driver with
ifdefs.  Find a way to fix it without that.
