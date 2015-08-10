From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2 -mainline] cxgb4: missing curly braces in
 t4_setup_debugfs()
Date: Mon, 10 Aug 2015 14:27:14 -0700 (PDT)
Message-ID: <20150810.142714.1369087190107952860.davem@davemloft.net>
References: <20150808191525.GB8034@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44458 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932726AbbHJV1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 17:27:15 -0400
In-Reply-To: <20150808191525.GB8034@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Sat, 8 Aug 2015 22:15:25 +0300

> There were missing curly braces so it means we call add_debugfs_mem()
> unintentionally.
> 
> Fixes: 3ccc6cf74d8c ('cxgb4: Adds support for T6 adapter')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied to 'net'.
