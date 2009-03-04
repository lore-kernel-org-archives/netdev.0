From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: more timeouts that reach -1
Date: Wed, 04 Mar 2009 00:10:21 -0800 (PST)
Message-ID: <20090304.001021.252964292.davem@davemloft.net>
References: <25e057c00902270737x529fb5b8m2fdbb044fa75ab0d@mail.gmail.com>
	<20090227154440.M53654@cooldavid.org>
	<49A8181A.5030106@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cooldavid@cooldavid.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40754
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752453AbZCDIKg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 03:10:36 -0500
In-Reply-To: <49A8181A.5030106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Fri, 27 Feb 2009 17:43:06 +0100

> Here are all three patches again with another issue I spotted in 
> drivers/net/ucc_geth_mii.c:
> 
> After my patch it still wouldn't err, because timeout was unsigned.

I'll make sure to integrate this version of your patch instead
of the original which I just said I applied :-)
