From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sunlance: beyond ARRAY_SIZE of ib->btx_ring
Date: Thu, 21 May 2009 13:34:24 -0700 (PDT)
Message-ID: <20090521.133424.258231675.davem@davemloft.net>
References: <4A15B95D.4050200@gmail.com>
	<4A15BA10.7080605@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56628
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755242AbZEUUeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 16:34:25 -0400
In-Reply-To: <4A15BA10.7080605@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Thu, 21 May 2009 22:31:12 +0200

> Do not go beyond ARRAY_SIZE of ib->btx_ring
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> Please ignore the other "X: ... patch"

You don't need to keep CC:'ing Jeff, he hasn't handled networking
device driver patches for some time now.
