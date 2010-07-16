From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] drivers: isdn: remove custom strtoul()
Date: Thu, 15 Jul 2010 19:08:30 -0700 (PDT)
Message-ID: <20100715.190830.229757509.davem@davemloft.net>
References: <1279197440-6585-1-git-send-email-andy.shevchenko@gmail.com>
	<1279197440-6585-2-git-send-email-andy.shevchenko@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, isdn@linux-pingi.de,
	netdev@vger.kernel.org
To: andy.shevchenko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38798
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935419Ab0GPCIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 22:08:14 -0400
In-Reply-To: <1279197440-6585-2-git-send-email-andy.shevchenko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Thu, 15 Jul 2010 15:37:19 +0300

> In this case we safe to use strict_strtoul().
> 
> Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>

Applied.
