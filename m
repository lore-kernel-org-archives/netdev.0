From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Sun, 18 Sep 2011 23:00:56 -0400 (EDT)
Message-ID: <20110918.230056.538257203944383944.davem@davemloft.net>
References: <20110918.210344.570661374586887894.davem@davemloft.net>
	<CA+55aFyENEpGJmTq55=n0_gDiF6RQmdKw-ts4AdQAFQJ1TkF-Q@mail.gmail.com>
	<1316401043.2768.52.camel@pororo>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, david.ward@ll.mit.edu,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jk@ozlabs.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1316401043.2768.52.camel@pororo>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeremy Kerr <jk@ozlabs.org>
Date: Mon, 19 Sep 2011 10:57:23 +0800

> I've found the problem, and committed a fix & testcase:
> 
>  http://git.ozlabs.org/?p=patchwork;a=commitdiff;h=4bc2c34d
> 
> That fix has been applied to the patchwork.ozlabs.org instance, and I've
> manually updated the incorrect (ie, username-only) entries in the
> patchwork database.

Thanks a bunch Jeremy!
