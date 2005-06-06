From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Fix link failure in 5701
Date: Mon, 06 Jun 2005 15:27:22 -0700 (PDT)
Message-ID: <20050606.152722.31644561.davem@davemloft.net>
References: <1118086942.5008.14.camel@rh4>
	<20050606.151641.95895557.davem@davemloft.net>
	<20050606222631.GE12068@esmail.cup.hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, peterc@gelato.unsw.edu.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: iod00d@hp.com
In-Reply-To: <20050606222631.GE12068@esmail.cup.hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Grant Grundler <iod00d@hp.com>
Date: Mon, 6 Jun 2005 15:26:31 -0700

> Btw, where can I see which version of tg3 will get this fix?
> 
> I'm certainly I'll be asked the question "which tg3 version
> is required" more than the few times.

It will be version "3.30" with release date "June 6, 2005"

I will push it to Linus as soon as the kernel.org mirror
system picks it up from my GIT tree at:

       rsync://rsync.kernel.org/pub/scm/linux/kernel/git/davem/tg3-2.6.git/
