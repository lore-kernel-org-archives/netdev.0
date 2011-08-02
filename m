From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb3i: ref count cdev access to prevent modification
 while in use
Date: Mon, 01 Aug 2011 17:36:44 -0700 (PDT)
Message-ID: <20110801.173644.513797128993481318.davem@davemloft.net>
References: <1311623817-6417-1-git-send-email-nhorman@tuxdriver.com>
	<20110801111824.GB23131@hmsreliant.think-freely.org>
	<4E36BB71.6050400@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org, divy@chelsio.com,
	swise@chelsio.com, kxie@chelsio.com
To: swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54954 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475Ab1HBAiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 20:38:06 -0400
In-Reply-To: <4E36BB71.6050400@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>
Date: Mon, 01 Aug 2011 09:42:57 -0500

> 
>>> Signed-off-by: Neil Horman<nhorman@tuxdriver.com>
>>> CC: Divy Le Ray<divy@chelsio.com>
>>> CC: Steve Wise<swise@chelsio.com>
>>> CC: "David S. Miller"<davem@davemloft.net>
>> Divy, Steve, I think Dave is waiting for an ACK from one of you to,
>> since you're
>> the listed maintainers.
>> Neil
> 
> Karen is the cxgb3i maintainer, but I just now reviewed the patch and
> it looks good.  Divy is on vacation for a few weeks.  I think its ok
> to pull it in since Karen already acked it.

And just to make clear this needs to go via the SCSI tree not via me.
