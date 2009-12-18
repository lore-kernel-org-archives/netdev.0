From: =?ISO-8859-1?Q?N=E9meth_M=E1rton?= <nm127@freemail.hu>
Subject: Re: [Bugme-new] [Bug 14794] New: IP address assigned by DHCP is
 dropped after ~40 seconds
Date: Fri, 18 Dec 2009 18:05:35 +0100
Message-ID: <4B2BB65F.6000703@freemail.hu>
References: <bug-14794-10286@http.bugzilla.kernel.org/>	<20091216154713.f082e7cf.akpm@linux-foundation.org>	<4B2A9A40.90203@freemail.hu>	<20091217132451.b168a796.akpm@linux-foundation.org>	<4B2AA64C.50709@gmail.com> <4B2B35B7.6060703@freemail.hu> <adaskb83df6.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail01a.mail.t-online.hu ([84.2.40.6]:53667 "EHLO
	mail01a.mail.t-online.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752767AbZLRRFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 12:05:40 -0500
In-Reply-To: <adaskb83df6.fsf@roland-alpha.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland Dreier wrote:
>  > Unfortunately reverting the commit 61cbe54d9479ad98283b2dda686deae=
4c34b2d59 on
>  > top of 2.6.32 does not solve the problem.
>=20
> Is there any possibility that one of the steps of the bisection was
> wrong?  Could you possibly have accidentally marked a "bad" kernel as
> "good"?

I am afraid that I might need to repeat the whole "git bisect" process =
because
reverting the found patch have not solved the problem...

Regards,

	M=E1rton N=E9meth
