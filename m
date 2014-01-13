From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] HHF qdisc: fix jiffies-time conversion.
Date: Mon, 13 Jan 2014 11:20:54 -0800 (PST)
Message-ID: <20140113.112054.12649738939941285.davem@davemloft.net>
References: <1389256800-18809-1-git-send-email-vtlam@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nanditad@google.com,
	stephen@networkplumber.org
To: vtlam@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38010 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbaAMTUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 14:20:55 -0500
In-Reply-To: <1389256800-18809-1-git-send-email-vtlam@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Terry Lam <vtlam@google.com>
Date: Thu,  9 Jan 2014 00:40:00 -0800

> This is to be compatible with the use of "get_time" (i.e. default
> time unit in us) in iproute2 patch for HHF as requested by Stephen.
> 
> Signed-off-by: Terry Lam <vtlam@google.com>

Applied, thank you.
