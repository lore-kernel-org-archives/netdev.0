From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sunlance: beyond ARRAY_SIZE of ib->btx_ring
Date: Thu, 21 May 2009 15:02:51 -0700 (PDT)
Message-ID: <20090521.150251.73444112.davem@davemloft.net>
References: <4A15B95D.4050200@gmail.com>
	<4A15BA10.7080605@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42419
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754712AbZEUWCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 18:02:53 -0400
In-Reply-To: <4A15BA10.7080605@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Thu, 21 May 2009 22:31:12 +0200

> Do not go beyond ARRAY_SIZE of ib->btx_ring
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

What in the world are you generating this patch against?

Linus's tree already has this change, for months.

And it was added by you, in February!

commit b956d41162b1f2c4b446107e9910e4719cbc75f4
Author: Roel Kluin <roel.kluin@gmail.com>
Date:   Sat Feb 21 23:46:36 2009 -0800

    sunlance: Beyond ARRAY_SIZE of ib->btx_ring
    
    Do not go beyond ARRAY_SIZE of ib->btx_ring
    
    Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

