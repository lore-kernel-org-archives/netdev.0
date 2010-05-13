From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/4] xfrm: add x86 CONFIG_COMPAT support
Date: Wed, 12 May 2010 23:41:59 -0700 (PDT)
Message-ID: <20100512.234159.229770923.davem@davemloft.net>
References: <1270506431-25578-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36352
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751781Ab0EMGlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 02:41:51 -0400
In-Reply-To: <1270506431-25578-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm officially deferring this patch set for now, sorry.

I can't see applying this if it will fix only some subset of
known applications.  We need buy-in on the read/write vfs ops
override so we can do this properly.

Thanks for all of your efforts Florian.
