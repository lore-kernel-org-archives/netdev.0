From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mcast: do not check 'rv' twice in a row
Date: Mon, 04 Feb 2013 13:33:50 -0500 (EST)
Message-ID: <20130204.133350.467438047415006272.davem@davemloft.net>
References: <1359963250-7729-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sakiwit@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44134 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754500Ab3BDSdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 13:33:54 -0500
In-Reply-To: <1359963250-7729-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>
Date: Mon,  4 Feb 2013 00:34:10 -0700

> With the loop, don't check 'rv' twice in a row. Without the loop, 'rv'
> doesn't even need to be checked.
> 
> Make the comment more grammar-friendly.
> 
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>

Applied.
