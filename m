From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 14794] New: IP address assigned by DHCP is
 dropped after ~40 seconds
Date: Sat, 19 Dec 2009 14:48:06 +0100
Message-ID: <20091219134805.GA2612@ami.dom.local>
References: <bug-14794-10286@http.bugzilla.kernel.org/>
 <20091216154713.f082e7cf.akpm@linux-foundation.org>
 <4B2A9A40.90203@freemail.hu>
 <20091217132451.b168a796.akpm@linux-foundation.org>
 <4B2AA64C.50709@gmail.com>
 <4B2B35B7.6060703@freemail.hu>
 <4B2BB27D.5050609@freemail.hu>
 <20091218200906.GA2604@ami.dom.local>
 <4B2CAA56.8030605@freemail.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: =?iso-8859-1?Q?N=E9meth_M=E1rton?= <nm127@freemail.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:34144 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbZLSNsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Dec 2009 08:48:17 -0500
Received: by fxm21 with SMTP id 21so3564683fxm.21
        for <netdev@vger.kernel.org>; Sat, 19 Dec 2009 05:48:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4B2CAA56.8030605@freemail.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 19, 2009 at 11:26:30AM +0100, N=E9meth M=E1rton wrote:
> I upgraded the Debian package "network-manager" from 0.6.6-3 to 0.7.2=
-2.
> The problem seems to be solved: the IP address is not dropped in 2.6.=
32
> and in 2.6.31. The conclusion is for me that a user-space program cau=
sed
> the problem, thanks for the hint.

Yes, Debian often fixes our bugs on time! ;-)

Thanks,
Jarek P.
