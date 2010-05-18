From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] xfrm: add severity to printk
Date: Mon, 17 May 2010 22:58:12 -0700 (PDT)
Message-ID: <20100517.225812.26961932.davem@davemloft.net>
References: <20100512163704.780058547@vyatta.com>
	<20100512163719.498741963@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56021
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754699Ab0ERF6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 01:58:04 -0400
In-Reply-To: <20100512163719.498741963@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 12 May 2010 09:37:06 -0700

> Serious oh sh*t messages converted to WARN().
> Add KERN_NOTICE severity to the unknown policy type messages.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
