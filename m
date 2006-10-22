From: David Miller <davem@davemloft.net>
Subject: Re: [IPv6] fib: initialize tb6_lock in common place to give
 lockdep a key
Date: Sat, 21 Oct 2006 20:21:54 -0700 (PDT)
Message-ID: <20061021.202154.73698519.davem@davemloft.net>
References: <20061020124204.GW12964@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:50609
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422928AbWJVDVt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Oct 2006 23:21:49 -0400
To: tgraf@suug.ch
In-Reply-To: <20061020124204.GW12964@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 20 Oct 2006 14:42:04 +0200

> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks a lot for this fix Thomas.
