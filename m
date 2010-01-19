From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] S2io: two branches the same in
 wait_for_cmd_complete()
Date: Tue, 19 Jan 2010 12:36:27 -0800 (PST)
Message-ID: <20100119.123627.67488916.davem@davemloft.net>
References: <1263936009.14256.32.camel@flash>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roel.kluin@gmail.com
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41641
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752904Ab0ASUgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 15:36:17 -0500
In-Reply-To: <1263936009.14256.32.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ramkrishna Vepa <ram.vepa@neterion.com>
Date: 19 Jan 2010 13:20:09 -0800

> Fix check to verify if a register bit is set. We have not hit this bug because
> wait_for_cmd_complete() is always called with S2IO_BIT_RESET. 
> Reported by Roel Kluin <roel.kluin@gmail.com>.
> 
> Signed-off-by: Ram Vepa <ram.vepa@neterion.com>

Applied, thanks.
