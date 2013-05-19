From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Documentation/sysctl/net.txt: fix (attribute
 removal).
Date: Sun, 19 May 2013 15:13:24 -0700 (PDT)
Message-ID: <20130519.151324.2280887229712891869.davem@davemloft.net>
References: <1368817834-5915-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49261 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752327Ab3ESWNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 May 2013 18:13:25 -0400
In-Reply-To: <1368817834-5915-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Fri, 17 May 2013 22:10:34 +0300

> This patch removes mentioning the sysfsf net_device weight attribute
> (class/net/<device>/weight)  
> in Documentation/sysctl/net.txt, since the net sysfs weight attribute
> was removed by the following patch:
> 
> [NET]: Make NAPI polling independent of struct net_device objects
>  bea3348eef27e6044b6161fd04c3152215f96411
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks.
