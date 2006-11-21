From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Tue, 21 Nov 2006 15:01:45 -0500
Message-ID: <45635B29.4000801@garzik.org>
References: <11630606361046@2ka.mipt.ru> <45564EA5.6020607@redhat.com> <20061113105458.GA8182@2ka.mipt.ru> <4560F07B.10608@redhat.com> <20061120082500.GA25467@2ka.mipt.ru> <4562102B.5010503@redhat.com> <20061121095302.GA15210@2ka.mipt.ru> <45633049.2000209@redhat.com> <20061121174334.GA25518@2ka.mipt.ru> <20061121184605.GA7787@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ulrich Drepper <drepper@redhat.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Alexander Viro <aviro@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38107 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1031351AbWKUUCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Nov 2006 15:02:00 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061121184605.GA7787@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nitpick:  in ring_buffer.c (example app), I would use posix_memalign(3) 
rather than malloc(3)

	Jeff




