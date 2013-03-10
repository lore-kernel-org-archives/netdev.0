From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: remove superfluous nla_data() NULL pointer checks
Date: Sun, 10 Mar 2013 16:47:02 -0400 (EDT)
Message-ID: <20130310.164702.655407434212338689.davem@davemloft.net>
References: <1362844620-13035-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: minipli@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227Ab3CJUqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 16:46:53 -0400
In-Reply-To: <1362844620-13035-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>
Date: Sat,  9 Mar 2013 16:57:00 +0100

> nla_data() cannot return NULL, so these NULL pointer checks are
> superfluous.
> 
> Signed-off-by: Mathias Krause <minipli@googlemail.com>

Applied to net-next, thanks.
