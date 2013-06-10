From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] rcu: fix a race in hlist_nulls_for_each_entry_rcu
 macro
Date: Mon, 10 Jun 2013 11:51:57 -0700
Message-ID: <1370890317.3252.10.camel@edumazet-glaptop>
References: <1370229169.24311.119.camel@edumazet-glaptop>
	 <20130602.202703.1059637861388689182.davem@davemloft.net>
	 <20130603034254.GC29614@linux.vnet.ibm.com>
	 <20130602.204915.334823676645400072.davem@davemloft.net>
	 <51B61B22.2010604@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	klamm@yandex-team.ru, brouer@redhat.com, dipankar@in.ibm.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, David.Laight@ACULAB.COM, stable@vger.kernel.org,
	gregkh@linuxfoundation.org
To: zhmurov@yandex-team.ru
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <51B61B22.2010604@yandex-team.ru>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-06-10 at 22:29 +0400, Boris B. Zhmurov wrote:

> Hello David,
> 
> Do you think, this patch is "stable material" and should be included in
> 3.0-stable and 3.4-stable trees? Thanks.

Yes, its in the stable queue :

http://patchwork.ozlabs.org/bundle/davem/stable/?state=*
