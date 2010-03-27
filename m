From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv4: Cleanup struct net dereference in
 rt_intern_hash
Date: Fri, 26 Mar 2010 20:58:14 -0700 (PDT)
Message-ID: <20100326.205814.106023370.davem@davemloft.net>
References: <4BAA4F35.3000903@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, nhorman@tuxdriver.com, netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52379
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752648Ab0C0D5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 23:57:51 -0400
In-Reply-To: <4BAA4F35.3000903@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 24 Mar 2010 20:43:17 +0300

> There's no need in getting it 3 times and gcc isn't smart enough
> to understand this himself.
> 
> This is just a cleanup before the fix (next patch).
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
