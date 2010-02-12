From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7] be2net: minor code optimizations
Date: Fri, 12 Feb 2010 12:29:29 -0800 (PST)
Message-ID: <20100212.122929.246592426.davem@davemloft.net>
References: <20100209113411.GA10498@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com, ajitkhaparde@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52532
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757629Ab0BLU3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 15:29:15 -0500
In-Reply-To: <20100209113411.GA10498@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitkhaparde@gmail.com>
Date: Tue, 9 Feb 2010 17:04:21 +0530

> Couple of code optimizations in the Rx path (to avoid a memset).
> 
> From: Sathya P <sathyap@serverengines.com>
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied to net-next-2.6
