From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [take12 1/3] kevent: Core files.
Date: Wed, 23 Aug 2006 11:23:52 +0200
Message-ID: <200608231123.52473.dada1@cosmosbay.com>
References: <115615558935@2ka.mipt.ru> <200608231051.37089.dada1@cosmosbay.com> <20060823091813.GA20014@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:57536 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S1751474AbWHWJXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 05:23:50 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060823091813.GA20014@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 23 August 2006 11:18, Evgeniy Polyakov wrote:
> On Wed, Aug 23, 2006 at 10:51:36AM +0200, Eric Dumazet (dada1@cosmosbay.com) 
wrote:
> > Hello Evgeniy
>
> Hi Eric.
>
> > I have one comment/suggestion (minor detail, your work is very good)
> >
> > I suggest to add one item in kevent_registered_callbacks[], so that
> > kevent_registered_callbacks[KEVENT_MAX] is valid and can act as a
> > fallback.
>
> Sounds good, could you please send appliable patch with proper
> signed-off line?

Unfortunately not at this moment, I'm quite busy at work, my boss will kill 
me :( .
If you find this good, please add it to your next patch submission or forget 
it. 

Thank you
Eric

