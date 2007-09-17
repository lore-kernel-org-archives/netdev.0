From: Satyam Sharma <satyam@infradead.org>
Subject: Re: 2.6.23-rc4-mm1 OOPS in forcedeth?
Date: Tue, 18 Sep 2007 05:26:08 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0709180516170.8863@enigma.security.iitk.ac.in>
References: <20070831215822.26e1432b.akpm@linux-foundation.org>
 <20070901181352.GA4156@amd64.of.nowhere> <46D9B7EF.2050109@garzik.org>
 <alpine.LFD.0.999.0709020610590.20781@enigma.security.iitk.ac.in>
 <20070902061900.GA5595@amd64.of.nowhere> <alpine.LFD.0.999.0709021504550.22654@enigma.security.iitk.ac.in>
 <20070913235133.0df3c590.ajwade+00@andrew.wade.networklinux.net>
 <20070917135729.GA19802@linux.vnet.ibm.com> <46EE8A13.1070102@sw.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Cc: Dhaval Giani <dhaval@linux.vnet.ibm.com>,
	Andrew James Wade <andrew.j.wade@gmail.com>,
	thunder7@xs4all.nl, Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev Mailing List <netdev@vger.kernel.org>,
	Manfred Spraul <manfred@colorfullife.com>
To: "Denis V. Lunev" <den@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:34401 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753611AbXIQXxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 19:53:42 -0400
In-Reply-To: <46EE8A13.1070102@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 17 Sep 2007, Denis V. Lunev wrote:
> Dhaval Giani wrote:
> > On Thu, Sep 13, 2007 at 11:51:33PM -0400, Andrew James Wade wrote:

> >> EIP: [<c037d81b>] tcp_rto_min+0xb/0x15 SS:ESP 0068:c0596dec

As Vlad Yasevich mentioned, this one is already fixed in 23-rc6.

The forcedeth oops is unrelated, but multiple people have reported that
same oops now -- adding Manfred Spraul to CC. [ original thread is at:
http://lkml.org/lkml/2007/9/1/115 ]
