From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] syncookies: remove Kconfig text line about
 disabled-by-default
Date: Fri, 04 Jun 2010 15:57:02 -0700 (PDT)
Message-ID: <20100604.155702.115919448.davem@davemloft.net>
References: <1275561750-24111-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45087
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757121Ab0FDW4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 18:56:53 -0400
In-Reply-To: <1275561750-24111-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu,  3 Jun 2010 12:42:30 +0200

> syncookies default to on since
> e994b7c901ded7200b525a707c6da71f2cf6d4bb
> (tcp: Don't make syn cookies initial setting depend on CONFIG_SYSCTL).
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks Florian.
