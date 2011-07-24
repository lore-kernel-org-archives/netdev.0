From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: c_can: remove duplicated #include
Date: Sat, 23 Jul 2011 20:01:55 -0700 (PDT)
Message-ID: <20110723.200155.1605700963105746430.davem@davemloft.net>
References: <1311409180-2988-1-git-send-email-weiyi.huang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: weiyi.huang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32936 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832Ab1GXDB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2011 23:01:57 -0400
In-Reply-To: <1311409180-2988-1-git-send-email-weiyi.huang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huang Weiyi <weiyi.huang@gmail.com>
Date: Sat, 23 Jul 2011 16:19:40 +0800

> Remove duplicated #include('s) in
>   drivers/net/can/c_can/c_can.c
>   drivers/net/can/c_can/c_can_platform.c
> 
> Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>

Applied.
