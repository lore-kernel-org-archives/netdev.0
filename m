From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take28-resend_1->0 0/8] kevent: Generic event handling mechanism.
Date: Thu, 21 Dec 2006 17:23:37 +0300
Message-ID: <20061221142337.GA17204@2ka.mipt.ru>
References: <3154985aa0591036@2ka.mipt.ru> <11666924573643@2ka.mipt.ru> <20061221103539.GA4099@2ka.mipt.ru> <458A64E5.4050703@garzik.org> <20061221104918.GA16744@2ka.mipt.ru> <1166708885.3749.49.camel@localhost> <20061221140429.GA25214@2ka.mipt.ru> <1166710867.3749.56.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:53283 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965017AbWLUO1m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Dec 2006 09:27:42 -0500
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1166710867.3749.56.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 21, 2006 at 09:21:07AM -0500, jamal (hadi@cyberus.ca) wrote:
> > I just do not know _what_ else should be done not even for inclusion - 
> > but at least for some progress.
> 
> I know you are frustrated but stop doing the above like a broken vinyl
> record, it doesnt help your case. 

That's why I'm going to stop void resending completely.

> > You want libevent to be patched? Its site is currently down, but ok, I
> > will create a patch.
> > 
> 
> I promise in 2 weeks to migrate an app or two that i have that use
> libevent to your version if you have it by then. I will then test and
> give you my opinion. 

Ok, when site will be ready I will patch libevent and post patch or link
in this thread. I plan to complete it this week.

> cheers,
> jamal

-- 
	Evgeniy Polyakov
