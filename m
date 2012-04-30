From: David Miller <davem@davemloft.net>
Subject: Re: inconsistent lock/deadlock crash, vanilla 3.3.4, 32bit, tcp
Date: Mon, 30 Apr 2012 12:49:56 -0400 (EDT)
Message-ID: <20120430.124956.549873851265050903.davem@davemloft.net>
References: <1335688804.2900.83.camel@edumazet-glaptop>
	<1335689052.2900.86.camel@edumazet-glaptop>
	<4F9E18E9.5010503@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, denys@visp.net.lb, netdev@vger.kernel.org,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-kernel@vger.kernel.org
To: glommer@parallels.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F9E18E9.5010503@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Glauber Costa <glommer@parallels.com>
Date: Mon, 30 Apr 2012 01:45:29 -0300

> It wasn't my intent to change that, it was a mistake.

I very much regret succumbing to the unreasonable pressure to apply
your original patches.

We've come to learn that they were full of errors and that they needed
to cook for several more months before being included.
