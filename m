From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sungem: missing net_device_ops
Date: Thu, 19 Mar 2009 23:58:09 -0700 (PDT)
Message-ID: <20090319.235809.03003940.davem@davemloft.net>
References: <20090319235313.300e51a9@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37534
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751032AbZCTG6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 02:58:22 -0400
In-Reply-To: <20090319235313.300e51a9@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 19 Mar 2009 23:53:13 -0700

> Sungem driver only got partially converted to net_device_ops.
> Since this could cause bugs, please push this to 2.6.29
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
