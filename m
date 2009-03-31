From: Kyle McMartin <kyle@mcmartin.ca>
Subject: Re: [PATCH] Phonet:fix build problem
Date: Mon, 30 Mar 2009 22:41:24 -0400
Message-ID: <20090331024124.GA30601@bombadil.infradead.org>
References: <20090320115838.GA26371@orion> <20090321.165950.248659848.davem@davemloft.net> <a4423d670903211719m76baeab0k51f054058d6f5134@mail.gmail.com> <1237694320.25297.3.camel@localhost.localdomain> <20090322160629.GA23227@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>,
	Alexander Beregalov <a.beregalov@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org
To: Kyle McMartin <kyle@mcmartin.ca>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761913AbZCaClu@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090322160629.GA23227@bombadil.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 22, 2009 at 12:06:29PM -0400, Kyle McMartin wrote:
> On Sun, Mar 22, 2009 at 03:58:40AM +0000, James Bottomley wrote:
> > > > I think that platform's atomic_add() implementation should
> > > > be fixed instead.
> > > 
> > > It is parisc, CC added.
> > 
> > Looks like a macro argument screw up in atomic.h
> > 
> > This should fix it (uncompiled, of course).
> > 
> 
> Looks correct to me. Applied. Thanks everyone.
>

Oh, bah, want to resend that with a sign-off, James?

regards, Kyle
