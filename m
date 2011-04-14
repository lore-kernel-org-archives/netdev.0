From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: allow shifted access in smsc911x V2
Date: Wed, 13 Apr 2011 17:13:10 -0700 (PDT)
Message-ID: <20110413.171310.71105103.davem@davemloft.net>
References: <1302720621-7339-1-git-send-email-mathieu.poirier@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lee.jones@linaro.org, patches@linaro.org,
	rubini@gnudd.com, linus.walleij@linaro.org
To: mathieu.poirier@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41855
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751132Ab1DNANp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 20:13:45 -0400
In-Reply-To: <1302720621-7339-1-git-send-email-mathieu.poirier@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: mathieu.poirier@linaro.org
Date: Wed, 13 Apr 2011 12:50:21 -0600

> From: Mathieu J. Poirier <mathieu.poirier@linaro.org>
> 
> This is a revised patch that permits a shifted access to the
> LAN9221 registers.  More specifically:
> 
>  It adds a shift parameter in the platform_data.
>  It introduces an ops in smsc911x_data.
>  A choice of access function to use at run-time.
>  Four new shifted access function.
> 
> Signed-off-by: Mathieu Poirier <mathieu.poirier@linaro.org>
> Signed-off-by: Alessandro Rubini <rubini@gnudd.com>

Looks good, applied.
