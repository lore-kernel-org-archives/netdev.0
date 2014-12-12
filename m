From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/6] net-PPP: Deletion of a few unnecessary checks
Date: Fri, 12 Dec 2014 09:29:50 -0500 (EST)
Message-ID: <20141212.092950.1840808214143867233.davem@davemloft.net>
References: <5480DA32.8000201@users.sourceforge.net>
	<20141209.145447.2234157264287438778.davem@davemloft.net>
	<548A92E2.8090304@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, paulus@samba.org,
	linux-ppp@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org, julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <548A92E2.8090304@users.sourceforge.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 12 Dec 2014 08:01:54 +0100

>> Generally speaking, it is advisable to not leave error pointers in data
>> structures, even if they are about to be free'd up in an error path anyways.
>>
>> Therefore I do not like some of the patches in this series.
> 
> Can you give any more concrete feedback here?

I gave you very concrete feedback, I said exactly that I don't want
error pointers left in data structure members.

I cannot describe my requirements any more precisely than that.
