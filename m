From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] atm: [lec] initialize .netdev_ops before calling
 register_netdev()
Date: Tue, 08 Dec 2009 20:22:43 -0800 (PST)
Message-ID: <20091208.202243.179170999.davem@davemloft.net>
References: <200912041519.nB4FJUs4027018@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50889
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753241AbZLIEWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 23:22:37 -0500
In-Reply-To: <200912041519.nB4FJUs4027018@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Date: Fri, 04 Dec 2009 10:19:30 -0500

> From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
> 
> atm: [lec] initialize .netdev_ops before calling register_netdev()
> 
> fix oops when initializing lane interfaces. lec should probably be
> changed to use alloc_netdev() instead.
> 
> Signed-off-by: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

Applied.
