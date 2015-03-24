From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove never used forwarding_accel_ops pointer
 from net_device
Date: Tue, 24 Mar 2015 12:44:19 -0400 (EDT)
Message-ID: <20150324.124419.637505012204914427.davem@davemloft.net>
References: <73a15123e8cbe6771ac6659ba39e17b3ea84975c.1427131748.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37487 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854AbbCXQo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 12:44:26 -0400
In-Reply-To: <73a15123e8cbe6771ac6659ba39e17b3ea84975c.1427131748.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 23 Mar 2015 18:40:02 +0100

> Cc: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> Hi John,
> 
> I guess it slipped in by accident?

That's how it looks to me, applied, thanks.
