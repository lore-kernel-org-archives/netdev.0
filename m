From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: check the length of the socket address passed to
 connect(2)
Date: Thu, 01 Apr 2010 17:26:57 -0700 (PDT)
Message-ID: <20100401.172657.127197382.davem@davemloft.net>
References: <4BB46032.7030500@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60850
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755907Ab0DBA04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 20:26:56 -0400
In-Reply-To: <4BB46032.7030500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Thu, 01 Apr 2010 16:58:26 +0800

> check the length of the socket address passed to connect(2).
> 
> Check the length of the socket address passed to connect(2). If the
> length is invalid, -EINVAL will be returned.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied.
