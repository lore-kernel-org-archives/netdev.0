From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: sock_bindtodevice() RCU-ification
Date: Thu, 05 Nov 2009 21:08:30 -0800 (PST)
Message-ID: <20091105.210830.108657873.davem@davemloft.net>
References: <4AF201FC.3040908@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52508
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754080AbZKFFIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 00:08:05 -0500
In-Reply-To: <4AF201FC.3040908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Nov 2009 23:36:44 +0100

> Avoid dev_hold()/dev_put() in sock_bindtodevice()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next-2.6, thanks.
