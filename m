From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: tg3: strange errors and non-working-ness
Date: Thu, 15 Nov 2007 23:11:10 +0100
Message-ID: <473CC3FE.5080509@o2.pl>
References: <20071115094728.GB2366@ff.dom.local> <1195154603.6360.9.camel@dell>	 <cccedfc60711151117v70b285fbl79bbc92ced176d54@mail.gmail.com>	 <1195158200.6360.17.camel@dell> <cccedfc60711151221p322894f8i94c540fefb0e4827@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, netdev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Jon Nelson <jnelson@jamponi.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:57935 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762053AbXKOWJO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 17:09:14 -0500
In-Reply-To: <cccedfc60711151221p322894f8i94c540fefb0e4827@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jon Nelson wrote, On 11/15/2007 09:21 PM:
...

> NOTE: to avoid list noise, I can make a bug out of this on
> bugzilla.kernel.org and we can proceed from there if that is
> preferred.

Why avoid list noise? These lists are made just for this. But, since
this case needs a lot of space for your configs, maybe a lot of time,
and maybe a bit more people to have a look at this as well, bugzilla
could be very useful.

Of course, like Michael said, it would be better if you could do
at least short test with a version as new as possible.

Regards,
Jarek P.

PS: I've forgot to mention: lspci -vv, cat /proc/interrupts
and maybe the same for these other, working gig-e cards.
