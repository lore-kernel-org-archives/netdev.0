From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net/dsa/dsa.c: remove null test before kfree
Date: Sat, 21 Jun 2014 19:22:43 -0700 (PDT)
Message-ID: <20140621.192243.435372238194944118.davem@davemloft.net>
References: <b991e868-c253-4b1a-8c95-56106c36d512@email.android.com>
	<20140621113653.6b2dd148b35a6ecfb7c08cce@skynet.be>
	<1403359806.4076.50.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fabf@skynet.be, bjorn@mork.no, linux-kernel@vger.kernel.org,
	grant.likely@linaro.org, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403359806.4076.50.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sat, 21 Jun 2014 07:10:06 -0700

> In this case, it seems the simple substitution of
> "unnecessary null" to the subject would have been
> enough validation.

Agreed.
