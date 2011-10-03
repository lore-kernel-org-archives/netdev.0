From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] pch_gbe: Fixed the issue on which PC was frozen
 when link was downed.
Date: Mon, 03 Oct 2011 14:25:54 -0400 (EDT)
Message-ID: <20111003.142554.1957747149860835445.davem@davemloft.net>
References: <1317022063-12143-1-git-send-email-toshiharu-linux@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, qi.wang@intel.com, yong.y.wang@intel.com,
	joel.clark@intel.com, kok.howg.ewe@intel.com,
	tomoya-linux@dsn.okisemi.com
To: toshiharu-linux@dsn.okisemi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53221 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932263Ab1JCS0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 14:26:04 -0400
In-Reply-To: <1317022063-12143-1-git-send-email-toshiharu-linux@dsn.okisemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Date: Mon, 26 Sep 2011 16:27:42 +0900

> When a link was downed during network use,
> there is an issue on which PC freezes.
> 
> This patch fixed this issue.
> 
> Signed-off-by: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>

Applied.
