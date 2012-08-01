From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: iputils git tree
Date: Wed, 01 Aug 2012 13:18:33 +0900
Message-ID: <5018AE19.7050002@linux-ipv6.org>
References: <201203182107.43855.vapier@gentoo.org> <20120801024656.GK11095@morgul.net> <20120731.202918.621064199466580610.davem@davemloft.net> <20120801040957.GL11095@morgul.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	vapier@gentoo.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Noah Meyerhans <frodo@morgul.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:47311 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750888Ab2HAESh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2012 00:18:37 -0400
In-Reply-To: <20120801040957.GL11095@morgul.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

(2012=E5=B9=B408=E6=9C=8801=E6=97=A5 13:09), Noah Meyerhans wrote:
> On Tue, Jul 31, 2012 at 08:29:18PM -0700, David Miller wrote:
>> iputils has been unmaintained for at least 2 years.
>>
>> Someone needs to step up and take over maintainence of it.
>>
>> Otherwise, expect the current situation to continue.
>
> I was under the impresion that iputils had been handed over from Alex=
ey
> to Hideaki YOSHIFUJI.  The fork at linux-ipv6.org certainly doesn't
> appear dead.  I count 12 commits this year to the repository visible =
at
> http://www.linux-ipv6.org/gitweb/gitweb.cgi?p=3Dgitroot/iputils.git;a=
=3Dsummary
> It's not exactly a screaming fast pace, but it's something.
>
> There are several (mostly relatively minor) bugs that have been fixed=
 in
> the Debian packages (of which I'm the maintainer). There's another
> assortment of patches in the Debian bug tracker that haven't yet been
> merged in.  I imagine Fedora and RHEL have a collection of similar
> modifications. So I suspect that iputils really isn't dead, but it's
> just that nobody's bothering to push changes back upstream. I'm more
> than happy to start doing so.
>
> noah
>

In fact my first motivation was to integrate Debian, Fedora and
other distro updates in to single source.  I sometimes look
into their sources and integrate some of their changes.

Anyway, I am happy if distro changes are posted and discussed.

Regards,

--yoshfuji
