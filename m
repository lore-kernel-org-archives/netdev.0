From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Wed, 22 Nov 2006 13:41:17 +0300
Message-ID: <20061122104114.GC11480@2ka.mipt.ru>
References: <45564EA5.6020607@redhat.com> <20061113105458.GA8182@2ka.mipt.ru> <4560F07B.10608@redhat.com> <20061120082500.GA25467@2ka.mipt.ru> <4562102B.5010503@redhat.com> <20061121095302.GA15210@2ka.mipt.ru> <45633049.2000209@redhat.com> <20061121174334.GA25518@2ka.mipt.ru> <20061121184605.GA7787@2ka.mipt.ru> <45635B29.4000801@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Ulrich Drepper <drepper@redhat.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Alexander Viro <aviro@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:51146 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1162022AbWKVKmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Nov 2006 05:42:09 -0500
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <45635B29.4000801@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 21, 2006 at 03:01:45PM -0500, Jeff Garzik (jeff@garzik.org) wrote:
> nitpick:  in ring_buffer.c (example app), I would use posix_memalign(3) 
> rather than malloc(3)

Yes, it can be done.

> 	Jeff

-- 
	Evgeniy Polyakov
