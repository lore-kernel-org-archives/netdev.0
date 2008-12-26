From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/27] drivers/net: fix sparse warning: use ANSI-style
 function declaration
Date: Thu, 25 Dec 2008 23:53:03 -0800 (PST)
Message-ID: <20081225.235303.188557355.davem@davemloft.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
	<20081222191458.11807.57800.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39566
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751870AbYLZHxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 02:53:01 -0500
In-Reply-To: <20081222191458.11807.57800.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Mon, 22 Dec 2008 20:14:58 +0100

> Fix this sparse warning:
> 
>   drivers/net/ne.c:932:24: warning: non-ANSI function declaration of function 'init_module'
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
