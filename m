From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] net: micrel: Staticize local functions
Date: Mon, 05 Aug 2013 11:10:25 -0700 (PDT)
Message-ID: <20130805.111025.464327135947916076.davem@davemloft.net>
References: <002301ce91ba$9605cc30$c2116490$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47547 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754321Ab3HESKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 14:10:25 -0400
In-Reply-To: <002301ce91ba$9605cc30$c2116490$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Mon, 05 Aug 2013 18:03:00 +0900

> These local functions are used only in this file.
> Fix the following sparse warnings:
 ...
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied.
