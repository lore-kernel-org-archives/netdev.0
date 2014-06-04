From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: driver: smsc: set NOCARRIER flag in dev at
 driver initialization
Date: Tue, 03 Jun 2014 18:21:21 -0700 (PDT)
Message-ID: <20140603.182121.1372144351492386070.davem@davemloft.net>
References: <538DFB44.6060902@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net
To: kumaran.4353@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50635 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510AbaFDBVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 21:21:22 -0400
In-Reply-To: <538DFB44.6060902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balakumaran Kannan <kumaran.4353@gmail.com>
Date: Tue, 03 Jun 2014 22:13:48 +0530

> As smsc driver supports carrier detection, it should unset NOCARRIER
> flag only after carrier state determination. By default that flag
> is off so driver should set it before starting auto-negotiation
> 
> Signed-off-by: Balakumaran <Balakumaran.Kannan@ap.sony.com>

Applied, thanks.
