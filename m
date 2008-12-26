From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/27] drivers/net: fix sparse warning: returning
 void-valued expression
Date: Thu, 25 Dec 2008 23:56:25 -0800 (PST)
Message-ID: <20081225.235625.171202833.davem@davemloft.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
	<20081222191517.11807.20718.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37903
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752821AbYLZH4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 02:56:23 -0500
In-Reply-To: <20081222191517.11807.20718.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Mon, 22 Dec 2008 20:15:17 +0100

> Fix this sparse warning:
> 
>   drivers/net/niu.c:8850:2: warning: returning void-valued expression
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Whilst, as stated, I disagree with this warning, I've
applied your patch.

Thanks.
