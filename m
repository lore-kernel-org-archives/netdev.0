From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 0/6] net-PPP: Deletion of a few unnecessary checks
Date: Fri, 12 Dec 2014 11:08:07 -0800
Message-ID: <1418411287.13491.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <548B0A29.8050503@users.sourceforge.net>
	 <20141212.105106.1162681032492664308.davem@davemloft.net>
	 <548B1E44.6050005@users.sourceforge.net>
	 <20141212.115922.687789059853236747.davem@davemloft.net>
	 <548B2468.5050402@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <548B2468.5050402@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-12-12 at 18:22 +0100, SF Markus Elfring wrote:

> Will it be acceptable for you that anyone (or even me) will introduce
> such a change with a seventh (and eventually eighth) update step here?
> Do you want any other sequence for source code preparation of
> the requested software improvement?

The thing is : We are in the merge window, tracking bugs added in latest
dev cycle.

Having to deal with patches like yours is adding pressure
on the maintainer (and other developers) at the wrong time.




