From: David Miller <davem@davemloft.net>
Subject: Re: [net-next patch v2] bnx2x: Improve code around
 bnx2x_tests_str_arr
Date: Mon, 24 Sep 2012 15:47:22 -0400 (EDT)
Message-ID: <20120924.154722.108033483182803916.davem@davemloft.net>
References: <1348405943-32605-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: meravs@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53645 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757620Ab2IXTrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 15:47:24 -0400
In-Reply-To: <1348405943-32605-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Merav Sicron" <meravs@broadcom.com>
Date: Sun, 23 Sep 2012 15:12:23 +0200

> This patch changes the definition of bnx2x_tests_str_arr from static char
> pointer to static const char bi-directional array. Also the
> bnx2x_get_strings function is simplified.
> 
> Reported-by: Joe Perches <joe@perches.com>
> Reported-by: David Laight <David.Laight@ACULAB.COM>
> Signed-off-by: Merav Sicron <meravs@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks.
