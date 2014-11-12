From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Fix static checker warning
Date: Wed, 12 Nov 2014 15:05:39 -0500 (EST)
Message-ID: <20141112.150539.2293601048996598747.davem@davemloft.net>
References: <1415784666-30224-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46089 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190AbaKLUFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 15:05:41 -0500
In-Reply-To: <1415784666-30224-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed, 12 Nov 2014 15:01:06 +0530

> Fix static checker warning that got introduced in commit e2ac9628959cc152
> ("cxgb4: Cleanup macros so they follow the same style and look consistent, part
> 2") due to accidental checkin of bogus line.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.
