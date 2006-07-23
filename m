From: David Miller <davem@davemloft.net>
Subject: Re: [AX.25 1/2] Introduce struct ax25_sock.
Date: Sat, 22 Jul 2006 17:05:44 -0700 (PDT)
Message-ID: <20060722.170544.21927031.davem@davemloft.net>
References: <20060721152946.GA16317@linux-mips.org>
	<20060722.013618.71088903.davem@davemloft.net>
	<20060722121343.GA7579@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:4574
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750755AbWGWAFl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jul 2006 20:05:41 -0400
To: ralf@linux-mips.org
In-Reply-To: <20060722121343.GA7579@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Sat, 22 Jul 2006 08:13:43 -0400

> While this patch itself is more of a cleanup it's a prerequisite for
> being able the use the sk_*_timer functions to fix the reference counts
> in AX.25 timers ...

When you have those timer refcount fixes as part of your patch set, I
can then justify putting the change into 2.6.18.  Feel free to
resubmit once you have it all ready.
