From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Fix trace observed while dumping
 clip_tbl
Date: Sun, 08 Feb 2015 21:56:09 -0800 (PST)
Message-ID: <20150208.215609.641497778778736327.davem@davemloft.net>
References: <1423455430-13444-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37373 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822AbbBIF4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 00:56:10 -0500
In-Reply-To: <1423455430-13444-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Mon,  9 Feb 2015 09:47:10 +0530

> Handle clip_tbl debugfs entry, when clip_tbl isn't allocated.
> In commit b5a02f503caa0837 ("cxgb4: Update ipv6 address handling api") wrong
> argument was passed for single_open for clip_tbl debugfs entry, which led to
> below trace. Fixing it.
 ...
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied.
