From: =?ISO-8859-1?Q?N=E9meth_M=E1rton?= <nm127@freemail.hu>
Subject: Re: [Bugme-new] [Bug 14794] New: IP address assigned by DHCP is	dropped
 after ~40 seconds
Date: Fri, 18 Dec 2009 17:17:52 +0100
Message-ID: <4B2BAB30.3030704@freemail.hu>
References: <bug-14794-10286@http.bugzilla.kernel.org/> <20091216154713.f082e7cf.akpm@linux-foundation.org> <4B2A9A40.90203@freemail.hu> <20091217132451.b168a796.akpm@linux-foundation.org> <4B2AA64C.50709@gmail.com> <4B2B35B7.6060703@freemail.hu> <adaskb83df6.fsf@roland-alpha.cisco.com> <20091218114123.GA8310@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roland Dreier <rdreier@cisco.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail01d.mail.t-online.hu ([84.2.42.6]:63031 "EHLO
	mail01d.mail.t-online.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932112AbZLRQSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 11:18:04 -0500
In-Reply-To: <20091218114123.GA8310@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Btw, I'm not sure if it matters, but your dmesg doesn't mirror what
> you described. You mentioned one unplug only, while there are a few
> link down / link up events visible. So I wonder if bad contact didn't

You are right, the dmesg I attached contains more plug and unplug event
because I really plugged and unplugged the network cable several times
to be sure that the IP address is always dropped. The wireshark log
contains only one unplug and plug, however.

Regards,

	M=E1rton N=E9meth

