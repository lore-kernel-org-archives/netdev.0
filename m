From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: lpc_eth: fix warnings caused by enabling
 unprepared clock
Date: Mon, 05 Oct 2015 03:42:01 -0700 (PDT)
Message-ID: <20151005.034201.2094658113776123883.davem@davemloft.net>
References: <1443649063-10817-1-git-send-email-vz@mleia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vz@mleia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38936 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423AbbJEK0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 06:26:22 -0400
In-Reply-To: <1443649063-10817-1-git-send-email-vz@mleia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladimir Zapolskiy <vz@mleia.com>
Date: Thu,  1 Oct 2015 00:37:43 +0300

> If common clock framework is configured, the driver generates warnings,
> which are fixed by this change:
 ...
> Signed-off-by: Vladimir Zapolskiy <vz@mleia.com>

Applied, thanks.
