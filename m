From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] af_mpls: add null dev check in find_outdev
Date: Thu, 06 Aug 2015 22:04:20 -0700 (PDT)
Message-ID: <20150806.220420.170102221275006429.davem@davemloft.net>
References: <1438695384-26306-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, ebiederm@xmission.com,
	rshearma@brocade.com, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45576 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752544AbbHGFEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 01:04:21 -0400
In-Reply-To: <1438695384-26306-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Tue,  4 Aug 2015 06:36:24 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch adds null dev check for the 'cfg->rc_via_table ==
> NEIGH_LINK_TABLE or dev_get_by_index() failed' case
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
> v1-v2 : fixed patch version

Applied, thanks.
