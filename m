From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/3] be2net: fix net-snmp error because of
 wrong packet stats
Date: Wed, 25 Aug 2010 14:23:06 -0700 (PDT)
Message-ID: <20100825.142306.59664520.davem@davemloft.net>
References: <20100825102534.GA14714@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60228
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752303Ab0HYVWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 17:22:51 -0400
In-Reply-To: <20100825102534.GA14714@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Wed, 25 Aug 2010 15:55:47 +0530

> Wrong packet statistics for multicast Rx was causing net-snmp error messages
> every 15 seconds. Instead of picking the multicast stats from hardware,
> now maintain it in the driver itself.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.
