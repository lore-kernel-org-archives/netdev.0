From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/9][v2] mISDN: un-export symbol 'plx_lock'
Date: Fri, 12 Dec 2008 21:16:21 -0800 (PST)
Message-ID: <20081212.211621.232812118.davem@davemloft.net>
References: <49419a2d.06a1660a.5c0a.ffff908c@mx.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kkeil@suse.de,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42640
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751134AbYLMFQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 00:16:19 -0500
In-Reply-To: <49419a2d.06a1660a.5c0a.ffff908c@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Thu, 11 Dec 2008 22:36:00 +0100

> 'plx_lock' is only used within hfcmulti.c.
> 
> Fix this warning:
> 
>   drivers/isdn/hardware/mISDN/hfcmulti.c:176:1: warning: symbol 'plx_lock' shadows an earlier one
>   drivers/isdn/hardware/mISDN/hfcmulti.c:175:19: originally declared here
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>
> Acked-by: Karsten Keil <kkeil@suse.de>

Applied.
