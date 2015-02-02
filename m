From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/8] cxgb4: Added support in debugfs to
 display tp_la stats
Date: Mon, 02 Feb 2015 13:14:36 -0800 (PST)
Message-ID: <20150202.131436.102902508236295371.davem@davemloft.net>
References: <1422888789-12016-1-git-send-email-hariprasad@chelsio.com>
	<1422888789-12016-3-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48341 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964927AbbBBVOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 16:14:37 -0500
In-Reply-To: <1422888789-12016-3-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Mon,  2 Feb 2015 20:23:03 +0530

> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Ok I've seen enough.

You guys really, truly, abuse debugfs.  So I'm putting my foot down now.

Stats like this can be exported through traditional means such as via
ethtool.
