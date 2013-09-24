From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] stable_kernel_rules.txt: Exclude networking from stable
	rules
Date: Tue, 24 Sep 2013 01:48:42 -0700
Message-ID: <20130924084842.GB11858@infradead.org>
References: <alpine.LRH.2.02.1309191229480.32035@file01.intranet.prod.int.rdu2.redhat.com>
	<20130919.135628.1201613770803318193.davem@davemloft.net>
	<alpine.LRH.2.02.1309191359300.12162@file01.intranet.prod.int.rdu2.redhat.com>
	<1379615474.22168.13.camel@joe-AO722>
	<20130922185104.GA7515@infradead.org>
	<1379968445.3575.60.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, linux-doc@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	LKML <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com,
	Christoph Hellwig <hch@infradead.org>,
	Mikulas Patocka <mpatocka@redhat.com>,
	Rob Landley <rob@landley.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <xfs-bounces@oss.sgi.com>
Content-Disposition: inline
In-Reply-To: <1379968445.3575.60.camel@joe-AO722>
List-Unsubscribe: <http://oss.sgi.com/mailman/options/xfs>,
	<mailto:xfs-request@oss.sgi.com?subject=unsubscribe>
List-Archive: <http://oss.sgi.com/pipermail/xfs>
List-Post: <mailto:xfs@oss.sgi.com>
List-Help: <mailto:xfs-request@oss.sgi.com?subject=help>
List-Subscribe: <http://oss.sgi.com/mailman/listinfo/xfs>,
	<mailto:xfs-request@oss.sgi.com?subject=subscribe>
Errors-To: xfs-bounces@oss.sgi.com
Sender: xfs-bounces@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 23, 2013 at 01:34:05PM -0700, Joe Perches wrote:
> Maybe adding a mechanism to MAINTAINERS would be better.
> Maybe a default B: (backport?) of stable@vger.kernel.org
> with a per-subsystem override?

Sounds fine to me.

_______________________________________________
xfs mailing list
xfs@oss.sgi.com
http://oss.sgi.com/mailman/listinfo/xfs
