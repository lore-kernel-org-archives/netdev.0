From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the akpm tree with the net-next
 tree
Date: Wed, 22 May 2013 00:07:48 -0700 (PDT)
Message-ID: <20130522.000748.454683591881350280.davem@davemloft.net>
References: <20130521142948.444f09820c5406f9adc4b7f1@canb.auug.org.au>
	<20130521130438.1ecdf535ab2461888abbe0c3@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, dborkman@redhat.com,
	netdev@vger.kernel.org, nschichan@freebox.fr
To: akpm@linux-foundation.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130521130438.1ecdf535ab2461888abbe0c3@linux-foundation.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 21 May 2013 13:04:38 -0700

> Nicolas, I think the patches need a re-check so I'll drop the versions
> which I presently have.  Please refresh, retest and resend when
> convenient?  It'll need to be against linux-next, which is where the
> conflicting (vfree/module_free) changes have occurred.

How about working against net-next and submitting your patches to netdev
just like the rest of the world?

There is zero reason for these changes to go through Andrew's tree.
