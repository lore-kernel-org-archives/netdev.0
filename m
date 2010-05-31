From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 4/4] atm: [he] rewrite buffer handling in
 receive path
Date: Mon, 31 May 2010 00:33:28 -0700 (PDT)
Message-ID: <20100531.003328.15260135.davem@davemloft.net>
References: <201005291905.o4TJ5XrX006431@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37715
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756624Ab0EaHdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 03:33:18 -0400
In-Reply-To: <201005291905.o4TJ5XrX006431@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Date: Sat, 29 May 2010 15:05:33 -0400

> From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
> 
> Author: chas williams - CONTRACTOR <chas@relax.cmf.nrl.navy.mil>
> Date:   Fri May 28 19:50:47 2010 -0400
> 
>     atm: [he] rewrite buffer handling in receive path
>     
>     Instead of a fixed list of buffers, use the buffer pool correctly and
>     keep track of the outstanding buffer indexes using a fixed table.
>     Resolves reported HBUF_ERR's -- failures due to lack of receive buffers.
>     
>     Signed-off-by: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

Applied.
