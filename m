From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix definition of netdev_for_each_mc_addr()
Date: Wed, 07 Apr 2010 16:40:17 -0700 (PDT)
Message-ID: <20100407.164017.238909355.davem@davemloft.net>
References: <20100407220100.13604.6636.stgit@mj.roinet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: proski@gnu.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59037
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751451Ab0DGXkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 19:40:15 -0400
In-Reply-To: <20100407220100.13604.6636.stgit@mj.roinet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Roskin <proski@gnu.org>
Date: Wed, 07 Apr 2010 18:01:52 -0400

> The first argument should be called ha, not mclist.  All callers use the
> name "ha", but if they used a different name, there would be a compile
> error.
> 
> Signed-off-by: Pavel Roskin <proski@gnu.org>

Applied, thank you.
