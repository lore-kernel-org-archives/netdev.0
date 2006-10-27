From: David Miller <davem@davemloft.net>
Subject: Re: [KJ] [Patch] kmemdup() cleanup in net/
Date: Thu, 26 Oct 2006 17:17:31 -0700 (PDT)
Message-ID: <20061026.171731.34759403.davem@davemloft.net>
References: <1161889418.7318.1.camel@alice>
	<1161895771.30263.1.camel@alice>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@lists.osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:55226
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1946050AbWJ0ARv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 20:17:51 -0400
To: snakebyte@gmx.de
In-Reply-To: <1161895771.30263.1.camel@alice>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Sesterhenn <snakebyte@gmx.de>
Date: Thu, 26 Oct 2006 22:49:31 +0200

> arg, i thought i compile tested everything, please use this
> version.
> 
> Signed-off-by: Eric Sesterhenn <snakebyte@gmx.de>

Definitely post-2.6.19 material, please resubmit when
2.6.20 merging opens up, thanks.
