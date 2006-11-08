From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take23 2/5] kevent: Core files.
Date: Wed, 8 Nov 2006 11:24:44 +0300
Message-ID: <20061108082444.GC2447@2ka.mipt.ru>
References: <1162918248891@2ka.mipt.ru> <11629182482529@2ka.mipt.ru> <20061107141657.b2378218.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:59557 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1754424AbWKHIZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 03:25:43 -0500
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061107141657.b2378218.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 07, 2006 at 02:16:57PM -0800, Andrew Morton (akpm@osdl.org) wrote:
> On Tue, 7 Nov 2006 19:50:48 +0300
> Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> 
> > This patch includes core kevent files:
> >  * userspace controlling
> >  * kernelspace interfaces
> >  * initialization
> >  * notification state machines
> 
> I fixed up all the rejects, but your syscall numbers changed.  Please
> always raise patches against the latest kernel.

Will do. NUmbers actually are the same, but added new syscall which was
against old tree.
Thanks Andrew.

-- 
	Evgeniy Polyakov
