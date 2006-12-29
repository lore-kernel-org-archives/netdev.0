From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take29 0/8] kevent: Generic event handling mechanism.
Date: Fri, 29 Dec 2006 11:48:37 +0300
Message-ID: <20061229084837.GA13816@2ka.mipt.ru>
References: <3154985aa0591036@2ka.mipt.ru> <11668927001365@2ka.mipt.ru> <20061228155645.GA7516@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:39152 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965031AbWL2IxP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Dec 2006 03:53:15 -0500
To: Ingo Molnar <mingo@elte.hu>
Content-Disposition: inline
In-Reply-To: <20061228155645.GA7516@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 28, 2006 at 04:56:45PM +0100, Ingo Molnar (mingo@elte.hu) wrote:
> 
> * Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> 
> > Generic event handling mechanism.
> 
> it would be /very/ helpful to state against which kernel tree the 
> patch-queue is. It does not apply to 2.6.20-rc1 nor to -rc2 nor to 
> 2.6.19. At which point i gave up ...

It was against 2.6.18 (d4397acde6fd047f13c744e5471a9bfe287f78a3) git.
Next patchset with possibility to inject already read event and
userspace reserved notifications will be against the latest tree (I will
push it today before final New Year celebration started).

> 	Ingo

-- 
	Evgeniy Polyakov
