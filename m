From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/6] net-PPP: Deletion of a few unnecessary checks
Date: Fri, 12 Dec 2014 15:07:41 -0500 (EST)
Message-ID: <20141212.150741.2169710971698369167.davem@davemloft.net>
References: <548B1E44.6050005@users.sourceforge.net>
	<20141212.115922.687789059853236747.davem@davemloft.net>
	<548B2468.5050402@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, paulus@samba.org,
	linux-ppp@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org, julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <548B2468.5050402@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 12 Dec 2014 18:22:48 +0100

>>> Where should "the error pointers" be stored instead?
>> A local variable, before you assign it into the datastructure.
> 
> Will it be acceptable for you that anyone (or even me) will introduce
> such a change with a seventh (and eventually eighth) update step here?
> Do you want any other sequence for source code preparation of
> the requested software improvement?

I'd like to honestly ask why you are being so difficult?

Everyone gets their code reviewed, everyone has to modify their
changes to adhere to the subsystem maintainer's wishes.  You
are not being treated specially, and quite frankly nobody is
asking anything unreasonable of you.
