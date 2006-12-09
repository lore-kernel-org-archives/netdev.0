From: Herbert Poetzl <herbert@13thfloor.at>
Subject: Re: [Devel] Re: Network virtualization/isolation
Date: Sat, 9 Dec 2006 20:04:14 +0100
Message-ID: <20061209190414.GA12377@MAIL.13thfloor.at>
References: <453F8800.9070603@fr.ibm.com> <1165239894.3664.61.camel@localhost> <m1k617u10x.fsf@ebiederm.dsl.xmission.com> <200612041900.42768.dim@openvz.org> <m1odqj8uyt.fsf@ebiederm.dsl.xmission.com> <4576AF68.2070604@sw.ru> <20061206183036.GA16927@MAIL.13thfloor.at> <m164cm2m9u.fsf@ebiederm.dsl.xmission.com> <20061209035002.GA11747@MAIL.13thfloor.at> <20061209112734.GA4646@irc.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Kirill Korotaev <dev@sw.ru>,
	Linux Containers <containers@lists.osdl.org>,
	Dmitry Mishin <dim@openvz.org>, netdev@vger.kernel.org,
	hadi@cyberus.ca, Stephen Hemminger <shemminger@osdl.org>,
	Andrew Morton <akpm@osdl.org>,
	Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MAIL.13thfloor.at ([213.145.232.33]:44500 "EHLO
	MAIL.13thfloor.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761818AbWLITEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Dec 2006 14:04:15 -0500
To: Tomasz Torcz <zdzichu@irc.pl>
Content-Disposition: inline
In-Reply-To: <20061209112734.GA4646@irc.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 09, 2006 at 12:27:34PM +0100, Tomasz Torcz wrote:
> On Sat, Dec 09, 2006 at 04:50:02AM +0100, Herbert Poetzl wrote:
> > On Fri, Dec 08, 2006 at 12:57:49PM -0700, Eric W. Biederman wrote:
> > > Herbert Poetzl <herbert@13thfloor.at> writes:
> > > 
> > > >> But, ok, it is not the real point to argue so much imho 
> > > >> and waste our time instead of doing things.
> > 
> > > > well, IMHO better talk (and think) first, then implement
> > > > something ... not the other way round, and then start
> > > > fixing up the mess ...
> > > 
> > > Well we need a bit of both.
> > 
> > hmm, are 'we' in a hurry here?
> > 
> > until recently, 'Linux' (mainline) didn't even want
> > to hear about OS Level virtualization, now there
> > is a rush to quickly get 'something' in, not knowing
> > or caring if it is usable at all?
> 
> Maybe beacuse other Operating Systems have it? 

well, that wasn't a good enough reason four years 
ago, when Linux-VServer tried to push a 'jail'
implementation into mainline (was called security
contexts back then, and maintained by Jacques Gelinas)

> For example Solaris' Crossbow...

yes, but the technology isn't really new, not even
on Linux and not even in the Open Source community

but don't get me wrong here, I'm absolutely for
having virtualization (or virtualization elements)
in mainline, I just don't want to see a Q&D hack
'we' have to suffer from the next two years :)

HTC,
Herbert

> -- 
> Tomasz Torcz               RIP is irrevelant. Spoofing is futile.
> zdzichu@irc.-nie.spam-.pl     Your routes will be aggreggated. -- Alex Yuriev
> 


