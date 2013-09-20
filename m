From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stable_kernel_rules.txt: Exclude networking from
 stable rules
Date: Fri, 20 Sep 2013 11:59:22 -0400 (EDT)
Message-ID: <20130920.115922.1753824753898372116.davem@davemloft.net>
References: <alpine.LRH.2.02.1309191359300.12162@file01.intranet.prod.int.rdu2.redhat.com>
	<1379615474.22168.13.camel@joe-AO722>
	<1379688880.2021.38.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	mpatocka@redhat.com, gregkh@linuxfoundation.org, rob@landley.net,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1379688880.2021.38.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Fri, 20 Sep 2013 07:54:40 -0700

> On Thu, 2013-09-19 at 11:31 -0700, Joe Perches wrote:
>> Networking is once again "special", so at least document
>> how it's working today in the hope that doing so makes
>> less work for all that actually read the documentation.
> 
> David, why did you mark this N/A is patchwork?
> It's your rule, why not document it?

Because it should go through whoever maintains that document, and
that isn't me.
