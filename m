From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: remove pathetic compile-command lines
Date: Wed, 03 Dec 2008 22:20:17 -0800 (PST)
Message-ID: <20081203.222017.27370118.davem@davemloft.net>
References: <20081203233526.GA2448@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44384
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750852AbYLDGUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 01:20:17 -0500
In-Reply-To: <20081203233526.GA2448@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Thu, 4 Dec 2008 02:35:26 +0300

> -m486, -O6 are partircularly amusing.
> 
> Remove some other useless lines near as well.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Even more amusing is that our build system was so crappy
long ago that these things were very useful :)

Applied, thanks!
