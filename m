From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] ipv4: remove an unused macro (FIB_RES_RESET).
Date: Thu, 07 May 2009 14:53:59 -0700 (PDT)
Message-ID: <20090507.145359.109823121.davem@davemloft.net>
References: <eb3ff54b0905070037n30a632b0jf51d177e5520eb57@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34435
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751444AbZEGVyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 17:54:03 -0400
In-Reply-To: <eb3ff54b0905070037n30a632b0jf51d177e5520eb57@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Thu, 7 May 2009 10:37:53 +0300

> Signed-off-by: Rami Rosen <ramirose@gmail.com>

This macro was already removed in the net-next-2.6 tree.

In fact, it was done by you! :-)

commit accc5b4f902b0ba83b2c6c48f2d9e7c204cef4a8
Author: Rami Rosen <ramirose@gmail.com>
Date:   Sun May 3 08:58:48 2009 +0000

    ipv4: remove unused macro (FIB_RES_RESET) from ip_fib.h.
    
    Signed-off-by: Rami Rosen <ramirose@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


