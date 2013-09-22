From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] stable_kernel_rules.txt: Exclude networking from stable
 rules
Date: Sun, 22 Sep 2013 11:51:04 -0700
Message-ID: <20130922185104.GA7515@infradead.org>
References: <alpine.LRH.2.02.1309191229480.32035@file01.intranet.prod.int.rdu2.redhat.com>
 <20130919.135628.1201613770803318193.davem@davemloft.net>
 <alpine.LRH.2.02.1309191359300.12162@file01.intranet.prod.int.rdu2.redhat.com>
 <1379615474.22168.13.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, Mikulas Patocka <mpatocka@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rob Landley <rob@landley.net>, linux-doc@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com
To: Joe Perches <joe@perches.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1379615474.22168.13.camel@joe-AO722>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is also the preferred way to do it for XFS.  Maybe word it in a way
that we can easily add subsystems.

To me it generally seems to be the best way to do it - having random Ccs
and lots of stable trees doesn't seem like a very good way of handling
it.

