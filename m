From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: igb: implement high frequency periodic
 output signals
Date: Wed, 08 Jul 2015 16:11:50 -0700 (PDT)
Message-ID: <20150708.161150.1028571714100873421.davem@davemloft.net>
References: <1436280102-30310-1-git-send-email-richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jacob.e.keller@intel.com,
	jeffrey.t.kirsher@intel.com, matthew.vick@intel.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38304 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316AbbGHXLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 19:11:51 -0400
In-Reply-To: <1436280102-30310-1-git-send-email-richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Tue,  7 Jul 2015 16:41:42 +0200

> In addition to interrupt driven target time output events, the i210
> also has two programmable clock outputs.  These clocks support periods
> between 16 nanoseconds and 140 milliseconds.  This patch implements
> the periodic output function using the clock outputs when possible,
> falling back to the target time for longer periods.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

I assume I will get this via the Intel folks in a future pull request.
