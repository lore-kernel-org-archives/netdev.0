From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: rocker: Use ether_addr_equal
Date: Fri, 01 May 2015 21:48:47 -0400 (EDT)
Message-ID: <20150501.214847.9214206308219613.davem@davemloft.net>
References: <1430374889-7479-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, sfeldma@gmail.com, netdev@vger.kernel.org
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41320 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837AbbEBBst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 21:48:49 -0400
In-Reply-To: <1430374889-7479-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Thu, 30 Apr 2015 15:21:29 +0900

> A small cleanup to make use of the ether_addr_equal helper.
> 
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Applied.
