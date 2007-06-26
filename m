From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Tue, 26 Jun 2007 10:08:34 +0200
Message-ID: <20070626080833.GA1740@ff.dom.local>
References: <4bacf17f0706161435g1bb7c08bpd427901f64d57fa@mail.gmail.com> <20070618110849.GA2450@ff.dom.local> <20070618081000.14da5186@localhost.localdomain> <20070619055007.GB1649@ff.dom.local> <4bacf17f0706220156j63c4ec4ah75ac13ba653a3e67@mail.gmail.com> <20070622133234.GA3756@ff.dom.local> <4bacf17f0706252310w155fc4d7v1bf12319a650559a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Marcin =?iso-8859-2?Q?=A6lusarz?= <marcin.slusarz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:43177 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751250AbXFZIAZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2007 04:00:25 -0400
Content-Disposition: inline
In-Reply-To: <4bacf17f0706252310w155fc4d7v1bf12319a650559a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 26, 2007 at 08:10:17AM +0200, Marcin =A6lusarz wrote:
=2E..=20
> I reproduced it on minimal config:
=2E..

Hm... This method is usable if you can find such minimal config
with which the bug cannot be reproduced. Then you can add more
until the bug is back. Of course, this takes time...

We know your hardware should be OK - since it was fine with 2.6.20.
We don't know how much your configs (kernel & apps) have changed.
Sometimes the change of kernel needs some apps to be recompiled too.
That's why it could be usable to try 2.6.21 from a live distro to
find if it's really kernel's fault.

And, alas, this log doesn't seem to tell nothing new...

Regards,
Jarek P.
