From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_packet: Quiet sparse noise about using plain
 integer as NULL pointer
Date: Wed, 08 Aug 2012 15:43:40 -0700 (PDT)
Message-ID: <20120808.154340.1114469845765533635.davem@davemloft.net>
References: <1344306430-30450-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47175 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753570Ab2HHWnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 18:43:40 -0400
In-Reply-To: <1344306430-30450-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Tue, 7 Aug 2012 10:27:10 +0800

> Quiets the sparse warning:
> warning: Using plain integer as NULL pointer
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Applied, thanks.
