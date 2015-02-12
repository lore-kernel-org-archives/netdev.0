From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx5_core: Fix configuration of log_uar_page_sz
Date: Wed, 11 Feb 2015 19:42:43 -0800 (PST)
Message-ID: <20150211.194243.2126950967947808936.davem@davemloft.net>
References: <20150211144038.GA18543@mtldesk30>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, clsoto@us.ibm.com, ogerlitz@mellanox.com
To: eli@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54477 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932184AbbBLDfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 22:35:41 -0500
In-Reply-To: <20150211144038.GA18543@mtldesk30>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@dev.mellanox.co.il>
Date: Wed, 11 Feb 2015 16:40:38 +0200

> The current code failed to configure the page size for architectures with page
> size different than 4K - PPC for example.
> 
> Signed-off-by: Carol L Soto <clsoto@us.ibm.com>
> Signed-off-by: Eli Cohen <eli@mellanox.com>

Applied.
