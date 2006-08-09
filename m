From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take6 1/3] kevent: Core files.
Date: Wed, 9 Aug 2006 23:17:18 +0400
Message-ID: <20060809191718.GA2102@2ka.mipt.ru>
References: <11551105592821@2ka.mipt.ru> <11551105602734@2ka.mipt.ru> <20060809104738.1498723f@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:20199 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751290AbWHITR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 15:17:56 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060809104738.1498723f@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2006 at 10:47:38AM -0700, Stephen Hemminger (shemminger@osdl.org) wrote:
> > +static inline void kevent_user_stat_increase_total(struct kevent_user *u)
> > +{
> > +	u->total++;
> > +}
> >
> 
> static wrapper_functions_with_execessive_long_names(struct i_really_hate *this)
> {
> 	suck();
> }

Understood...

-- 
	Evgeniy Polyakov
