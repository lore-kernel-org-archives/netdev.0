From: David Miller <davem@davemloft.net>
Subject: Re: bna: potential null dereference
Date: Sun, 12 Sep 2010 15:38:05 -0700 (PDT)
Message-ID: <20100912.153805.226772440.davem@davemloft.net>
References: <4C8242CA.3020906@gmail.com>
	<20100912.120230.71108625.davem@davemloft.net>
	<AANLkTi=cZyLYJac8b8MsyAA4HitCvpD3NaH7nifzHDLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jirislaby@gmail.com, ddutt@brocade.com, rmody@brocade.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: debdut@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=cZyLYJac8b8MsyAA4HitCvpD3NaH7nifzHDLw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Debashis Dutt <debdut@gmail.com>
Date: Sun, 12 Sep 2010 15:35:41 -0700

> A patch is on the way by tomorrow. BTW, this is just an unnecessary
> check that should be removed and not a NULL de-reference.

I've already made a fix in the net-next-2.6 tree.

You should send me fixes like this when you have them and are
reasonably confident of the change, which for something like
this should have been a day or two at most, not a week later.
