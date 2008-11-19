From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Cleanup of af_unix
Date: Wed, 19 Nov 2008 15:48:18 -0800 (PST)
Message-ID: <20081119.154818.02238416.davem@davemloft.net>
References: <4921133D.6070800@cosmosbay.com>
	<1226907282.4037.31.camel@localhost>
	<4921C3FD.106@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41179
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752193AbYKSXsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 18:48:18 -0500
In-Reply-To: <4921C3FD.106@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 17 Nov 2008 20:20:29 +0100

> [PATCH] net: af_unix should use KERN_INFO instead of KERN_DEBUG
> 
> As spotted by Joe Perches, we should use KERN_INFO in unix_sock_destructor()
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied.
