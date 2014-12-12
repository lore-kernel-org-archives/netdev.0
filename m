From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH v2 0/6] net-PPP: Deletion of a few unnecessary checks
Date: Fri, 12 Dec 2014 18:22:48 +0100
Message-ID: <548B2468.5050402@users.sourceforge.net>
References: <548B0A29.8050503@users.sourceforge.net>	<20141212.105106.1162681032492664308.davem@davemloft.net>	<548B1E44.6050005@users.sourceforge.net> <20141212.115922.687789059853236747.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: David Miller <davem@davemloft.net>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20141212.115922.687789059853236747.davem@davemloft.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Where should "the error pointers" be stored instead?
> A local variable, before you assign it into the datastructure.

Will it be acceptable for you that anyone (or even me) will introduce
such a change with a seventh (and eventually eighth) update step here?
Do you want any other sequence for source code preparation of
the requested software improvement?

Regards,
Markus
