From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/2] be2net: cleanup in case of error in
 be_open()
Date: Tue, 01 Jun 2010 00:19:52 -0700 (PDT)
Message-ID: <20100601.001952.123977548.davem@davemloft.net>
References: <20100531093345.GA2812@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42474
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751696Ab0FAHTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 03:19:42 -0400
In-Reply-To: <20100531093345.GA2812@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Mon, 31 May 2010 15:03:45 +0530

> This patch adds cleanup code (things like unregistering irq,
> disabling napi etc) to be_open() when an error occurs inside the
> routine.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
