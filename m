From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] stable_kernel_rules.txt: Exclude networking from stable
 rules
Date: Fri, 20 Sep 2013 00:37:59 +0200
Message-ID: <20130919223759.GA581@electric-eye.fr.zoreil.com>
References: <alpine.LRH.2.02.1309191229480.32035@file01.intranet.prod.int.rdu2.redhat.com>
 <20130919.135628.1201613770803318193.davem@davemloft.net>
 <alpine.LRH.2.02.1309191359300.12162@file01.intranet.prod.int.rdu2.redhat.com>
 <1379615474.22168.13.camel@joe-AO722>
 <20130919213241.GB31672@electric-eye.fr.zoreil.com>
 <1379627130.5862.2.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, Mikulas Patocka <mpatocka@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rob Landley <rob@landley.net>, linux-doc@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1379627130.5862.2.camel@joe-AO722>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe@perches.com> :
[...]
> David selects them regardless.
> 
> from Documentation/networking/netdev-FAQ.txt:

I don't believe that those who read Documentation/stable_kernel_rules.txt
will magically read networking/netdev-FAQ.txt as well nor figure that
while they should not mark the patches stables (skr.txt), they are
expected to apply some extra rules as well (nF.txt).

It's fine if you disagree. I won't argue.

-- 
Ueimor
