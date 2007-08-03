From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: NETPOLL=y , NETDEVICES=n compile error ( Re: 2.6.23-rc1-mm1 )
Date: Fri, 3 Aug 2007 09:30:31 +0200
Message-ID: <20070803073030.GB1582@ff.dom.local>
References: <20070731083210.GA1797@ff.dom.local> <46AF0B8C.7070006@googlemail.com> <20070731121735.GA1046@ff.dom.local> <46AF4F9C.5060000@googlemail.com> <20070801095920.GA1941@ff.dom.local> <20070802020219.GM11166@waste.org> <20070802090008.GA1699@ff.dom.local> <20070802155922.GQ11115@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gabriel C <nix.or.die@googlemail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jason.wessel@windriver.com, amitkale@linsyssoft.com,
	Sam Ravnborg <sam@ravnborg.org>
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:47403 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752939AbXHCHU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2007 03:20:57 -0400
Content-Disposition: inline
In-Reply-To: <20070802155922.GQ11115@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 02, 2007 at 10:59:23AM -0500, Matt Mackall wrote:
> On Thu, Aug 02, 2007 at 11:00:08AM +0200, Jarek Poplawski wrote:
> > On Wed, Aug 01, 2007 at 09:02:19PM -0500, Matt Mackall wrote:
...
> > > How about cc:ing the netpoll maintainer?
> > 
> > Is there a new one or do you suggest possibility of abusing the
> > authority of the netpoll's author with such trifles...?!
> 
> I'm just subtly suggesting that if you're going to have a discussion
> about netpoll, you ought to cc: me.

Thanks! I'm very honored. I've suspected there is some subtlety, but
wasn't sure of possible new patches to MAINTAINERS, so tried to be
subtle too...

> 
> > There are some notions about "other diagnostic tools" in some
> > net drivers, eg. 3c509.c, so there would be a little bit of
> > work if, after changing this, they really exist (and even if
> > not - maybe it's reasonable to save such possibility for the
> > future?).
> 
> I created it for netpoll, only netpoll clients have ever cared.

So, probably you're the best person to change this! Alas, it seems,
for some time any changes to netpoll could have a cold reception
here (pity for Ingo's laptop...).

Regards,
Jarek P.
