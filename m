From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/4] ipv6 and related cleanup for cxgb4/cxgb4i
Date: Tue, 14 Oct 2014 21:52:14 -0400 (EDT)
Message-ID: <20141014.215214.1506186384051746027.davem@davemloft.net>
References: <1413324791-12104-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com, leedom@chelsio.com,
	kxie@chelsio.com, manojmalviya@chelsio.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46396 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755536AbaJOBwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 21:52:19 -0400
In-Reply-To: <1413324791-12104-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Tue, 14 Oct 2014 15:13:07 -0700

> This patch set removes some duplicated/extraneous code from cxgb4i,
> and guards cxgb4 against compilation failure based on ipv6 tristate.

Sorry Anish, you can't have your Subject lines be the entire
content of your commit messages.

Write something more substantial in your logs, and make the
Subject line be a very concise summary.
