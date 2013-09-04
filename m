From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: fix the error to get the previous BD entry
Date: Wed, 04 Sep 2013 14:13:23 -0400 (EDT)
Message-ID: <20130904.141323.1646422023703023641.davem@davemloft.net>
References: <1378176078-10380-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b20596@freescale.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, stephen@networkplumber.org
To: B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43188 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756241Ab3IDSNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 14:13:24 -0400
In-Reply-To: <1378176078-10380-1-git-send-email-B38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <B38611@freescale.com>
Date: Tue, 3 Sep 2013 10:41:18 +0800

> Bug: error to get the previous BD entry. When the current BD
> is the first BD, the previous BD entry must be the last BD,
> not "bdp - 1" in current logic.
 ...
> Reviewed-by: Li Frank <B20596@freescale.com>
> Signed-off-by: Fugang Duan  <B38611@freescale.com>

Applied.
