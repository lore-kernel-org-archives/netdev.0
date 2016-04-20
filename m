From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] ila: Add struct definitions and helpers
Date: Tue, 19 Apr 2016 20:00:40 -0400 (EDT)
Message-ID: <20160419.200040.982311022858704534.davem@davemloft.net>
References: <1460752452-3328784-1-git-send-email-tom@herbertland.com>
	<1460752452-3328784-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38601 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752369AbcDTAAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 20:00:42 -0400
In-Reply-To: <1460752452-3328784-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Fri, 15 Apr 2016 13:34:10 -0700

> +	if (!ila_is_ila_addr(iaddr)) {

This doesn't compile.
