From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/3] be2net: fix net-snmp error because of
 wrong packet stats
Date: Fri, 03 Sep 2010 09:53:45 -0700 (PDT)
Message-ID: <20100903.095345.214228753.davem@davemloft.net>
References: <20100903161659.GA22700@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54487
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755815Ab0ICQx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 12:53:28 -0400
In-Reply-To: <20100903161659.GA22700@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Fri, 3 Sep 2010 21:47:10 +0530

> Wrong packet statistics for multicast Rx was causing net-snmp error messages
> every 15 seconds. Instead of picking the multicast stats from hardware,
> now maintain it in the driver itself.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.
