From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH v2 0/6] net-PPP: Deletion of a few unnecessary checks
Date: Fri, 12 Dec 2014 16:30:49 +0100
Message-ID: <548B0A29.8050503@users.sourceforge.net>
References: <5480DA32.8000201@users.sourceforge.net>	<20141209.145447.2234157264287438778.davem@davemloft.net>	<548A92E2.8090304@users.sourceforge.net> <20141212.092950.1840808214143867233.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141212.092950.1840808214143867233.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I gave you very concrete feedback, I said exactly that I don't want
> error pointers left in data structure members.

I find that your critique affects the proposed update steps four to six,
doesn't it?
Are the other steps acceptable in principle?


> I cannot describe my requirements any more precisely than that.

I hope that a bit more constructive suggestions will be contributed by
involved
software developers around the affected source code. Now it seems
that a small code clean-up becomes a more challenging development task.

How do you prefer to redesign corresponding data structures eventually?

Regards,
Markus
