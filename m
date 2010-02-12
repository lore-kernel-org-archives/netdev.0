From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7] be2net: change the driver description
Date: Fri, 12 Feb 2010 12:29:45 -0800 (PST)
Message-ID: <20100212.122945.263055691.davem@davemloft.net>
References: <20100209113755.GA10577@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com, ajitkhaparde@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52542
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757654Ab0BLU3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 15:29:30 -0500
In-Reply-To: <20100209113755.GA10577@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitkhaparde@gmail.com>
Date: Tue, 9 Feb 2010 17:08:06 +0530

> Since the driver is supporting multiple generations of the ASIC
> remove ASIC generation information from the driver description.
> This information is displayed by modinfo.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied to net-next-2.6
