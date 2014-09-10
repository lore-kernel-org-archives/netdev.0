From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] net: Convert pr_warning to pr_warn
Date: Wed, 10 Sep 2014 12:43:35 -0700 (PDT)
Message-ID: <20140910.124335.837039370159482619.davem@davemloft.net>
References: <cover.1410322181.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sage@inktank.com, ursula.braun@de.ibm.com,
	linux390@de.ibm.com, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, linux-kernel@vger.kernel.org,
	ceph-devel@vger.kernel.org, linux-s390@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1410322181.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue,  9 Sep 2014 21:17:27 -0700

> Remove remaining uses of pr_warning in net/
> 
> Joe Perches (5):
>   atm: Convert pr_warning to pr_warn
>   ceph: Convert pr_warning to pr_warn
>   pktgen: Convert pr_warning to pr_warn
>   iucv: Convert pr_warning to pr_warn
>   netfilter: Convert pr_warning to pr_warn

All except the ceph patch which is going via another tree.
