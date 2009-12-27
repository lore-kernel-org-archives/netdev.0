From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3 0/10] llc enhancements
Date: Sat, 26 Dec 2009 20:47:54 -0800 (PST)
Message-ID: <20091226.204754.27820368.davem@davemloft.net>
References: <1261864268-10460-1-git-send-email-opurdila@ixiacom.com>
	<20091226.203252.02261992.davem@davemloft.net>
	<20091226.203727.68115398.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@ghostprotocols.net,
	eric.dumazet@gmail.com
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36147
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751004AbZL0Ery (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2009 23:47:54 -0500
In-Reply-To: <20091226.203727.68115398.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sat, 26 Dec 2009 20:37:27 -0800 (PST)

> ERROR: "llc_sap_list" [net/llc/llc2.ko] undefined!
> make[1]: *** [__modpost] Error 1
> make: *** [modules] Error 2
> make: *** Waiting for unfinished jobs....
> 
> I'll fix this up, but next time please do some more build
> testing.

So I'm going to fix this by tossing patch #9 entirely.
