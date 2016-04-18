From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rtnetlink: rtnl_fill_stats: avoid an
 unnecssary stats copy
Date: Mon, 18 Apr 2016 13:40:56 -0400 (EDT)
Message-ID: <20160418.134056.874732068995453145.davem@davemloft.net>
References: <1460777785-43349-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54456 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533AbcDRRk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 13:40:57 -0400
In-Reply-To: <1460777785-43349-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Fri, 15 Apr 2016 20:36:25 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch passes netlink attr data ptr directly to dev_get_stats
> thus elimiating a stats copy.
> 
> Suggested-by: David Miller <davem@davemloft.net>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied.
