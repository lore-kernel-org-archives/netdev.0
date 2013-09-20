From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] stable_kernel_rules.txt: Exclude networking from stable
 rules
Date: Fri, 20 Sep 2013 07:54:40 -0700
Message-ID: <1379688880.2021.38.camel@joe-AO722>
References: <alpine.LRH.2.02.1309191229480.32035@file01.intranet.prod.int.rdu2.redhat.com>
	 <20130919.135628.1201613770803318193.davem@davemloft.net>
	 <alpine.LRH.2.02.1309191359300.12162@file01.intranet.prod.int.rdu2.redhat.com>
	 <1379615474.22168.13.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	Mikulas Patocka <mpatocka@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rob Landley <rob@landley.net>, linux-doc@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1379615474.22168.13.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-09-19 at 11:31 -0700, Joe Perches wrote:
> Networking is once again "special", so at least document
> how it's working today in the hope that doing so makes
> less work for all that actually read the documentation.

David, why did you mark this N/A is patchwork?
It's your rule, why not document it?
