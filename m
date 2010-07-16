From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] drivers: isdn: get rid of custom strtoul()
Date: Thu, 15 Jul 2010 19:08:38 -0700 (PDT)
Message-ID: <20100715.190838.35048648.davem@davemloft.net>
References: <1279197440-6585-1-git-send-email-andy.shevchenko@gmail.com>
	<1279197440-6585-3-git-send-email-andy.shevchenko@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, hjlipp@web.de, tilman@imap.cc,
	isdn@linux-pingi.de, gigaset307x-common@lists.sourceforge.net,
	netdev@vger.kernel.org
To: andy.shevchenko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38806
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935419Ab0GPCIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 22:08:23 -0400
In-Reply-To: <1279197440-6585-3-git-send-email-andy.shevchenko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Thu, 15 Jul 2010 15:37:20 +0300

> There were two methods isdn_gethex() and isdn_getnum() which are custom
> implementations of strtoul(). Get rid of them in regard to
> strict_strtoul() kernel's function.
> 
> Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>

Applied.
