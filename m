From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [net-next PATCH v3 0/10] llc enhancements
Date: Sun, 27 Dec 2009 14:02:56 +0200
Message-ID: <200912271402.56351.opurdila@ixiacom.com>
References: <1261864268-10460-1-git-send-email-opurdila@ixiacom.com> <20091226.203727.68115398.davem@davemloft.net> <20091226.204754.27820368.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@ghostprotocols.net,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:28784 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751503AbZL0MGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2009 07:06:17 -0500
In-Reply-To: <20091226.204754.27820368.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 27 December 2009 06:47:54 you wrote:
> From: David Miller <davem@davemloft.net>
> Date: Sat, 26 Dec 2009 20:37:27 -0800 (PST)
> 
> > ERROR: "llc_sap_list" [net/llc/llc2.ko] undefined!
> > make[1]: *** [__modpost] Error 1
> > make: *** [modules] Error 2
> > make: *** Waiting for unfinished jobs....
> >
> > I'll fix this up, but next time please do some more build
> > testing.
> 
> So I'm going to fix this by tossing patch #9 entirely.
> 

Sorry about that, patch #9 is completely wrong indeed. Next time I won't skip 
the full allmodconfig build.

Thanks !
