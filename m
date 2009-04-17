From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] macb: Handle Retry Limit Exceeded errors
Date: Fri, 17 Apr 2009 01:30:58 -0700 (PDT)
Message-ID: <20090417.013058.55300851.davem@davemloft.net>
References: <1239874331-9431-1-git-send-email-haavard.skinnemoen@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.ferre@atmel.com,
	erik.waling@konftel.se, erik.waling@konftel.com
To: haavard.skinnemoen@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53240
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753345AbZDQIbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 04:31:07 -0400
In-Reply-To: <1239874331-9431-1-git-send-email-haavard.skinnemoen@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Date: Thu, 16 Apr 2009 11:32:10 +0200

> When transfering large amounts of data we sometimes experienced that the
> Retry Limit Exceeded (RLE) bit got set in TSR during transmission
> attempts. When this happened the driver would stall in a state that
> prevented any more data from being sent.
> 
> Signed-off-by: Erik Waling <erik.waling@konftel.com>
> Signed-off-by: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>

Applied.
