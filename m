From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] X25: pushdown bkl in ioctls
Date: Fri, 19 Nov 2010 12:40:58 -0800 (PST)
Message-ID: <20101119.124058.28810620.davem@davemloft.net>
References: <1290122457.20070.57.camel@jaunty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew.hendry@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33548
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754289Ab0KSUkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 15:40:33 -0500
In-Reply-To: <1290122457.20070.57.camel@jaunty>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Hendry <andrew.hendry@gmail.com>
Date: Fri, 19 Nov 2010 10:20:57 +1100

> 
> Push down the bkl in the ioctls so they can be removed one at a time.
> 
> Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

Applied.
