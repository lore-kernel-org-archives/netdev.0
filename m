From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlge: remove duplicated #include
Date: Sat, 23 Jul 2011 20:02:08 -0700 (PDT)
Message-ID: <20110723.200208.1123846548780716373.davem@davemloft.net>
References: <1311409225-2340-1-git-send-email-weiyi.huang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-driver@qlogic.com, netdev@vger.kernel.org
To: weiyi.huang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32947 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101Ab1GXDCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2011 23:02:11 -0400
In-Reply-To: <1311409225-2340-1-git-send-email-weiyi.huang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huang Weiyi <weiyi.huang@gmail.com>
Date: Sat, 23 Jul 2011 16:20:25 +0800

> Remove duplicated #include('s) in
>   drivers/net/qlge/qlge_main.c
> 
> Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>

Applied.
