From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ks8851: Fix request_irq/free_irq mismatch
Date: Sat, 21 Apr 2012 15:56:11 -0400 (EDT)
Message-ID: <20120421.155611.867654197068869227.davem@davemloft.net>
References: <1334855837-28366-1-git-send-email-mjr@cs.wisc.edu>
	<4F9055DF.9050509@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mjr@cs.wisc.edu, ben@simtec.co.uk, netdev@vger.kernel.org
To: sboyd@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43548 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798Ab2DUT5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 15:57:24 -0400
In-Reply-To: <4F9055DF.9050509@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Boyd <sboyd@codeaurora.org>
Date: Thu, 19 Apr 2012 11:13:51 -0700

> On 04/19/12 10:17, mjr@cs.wisc.edu wrote:
>> From: Matt Renzelmann <mjr@cs.wisc.edu>
>>
>> The dev_id parameter passed to free_irq needs to match the one passed
>> to the corresponding request_irq.
>>
>> Signed-off-by: Matt Renzelmann <mjr@cs.wisc.edu>
> 
> Acked-by: Stephen Boyd <sboyd@codeaurora.org>

Applied, thanks.
