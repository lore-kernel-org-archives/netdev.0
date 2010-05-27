From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/11] drivers/net/hamradio: Eliminate a NULL pointer
 dereference
Date: Thu, 27 May 2010 16:29:19 -0700 (PDT)
Message-ID: <20100527.162919.115912825.davem@davemloft.net>
References: <Pine.LNX.4.64.1005271432450.5422@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpr@f6fbb.org, linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45074
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757240Ab0E0X3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 19:29:09 -0400
In-Reply-To: <Pine.LNX.4.64.1005271432450.5422@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Thu, 27 May 2010 14:33:00 +0200 (CEST)

> At the point of the print, dev is NULL.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
