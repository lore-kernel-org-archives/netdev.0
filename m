From: Wolfgang Rosner <wrosner@tirnet.de>
Subject: Re: One way TCP bottleneck over 6 x Gbit tecl aggregated link // Kernel issue
Date: Mon, 23 Mar 2015 10:05:01 +0100
Message-ID: <201503231005.02195.wrosner@tirnet.de>
References: <201503210110.48980.wrosner@tirnet.de> <201503230157.46489.wrosner@tirnet.de> <1427077997.25985.59.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tirnet.de ([217.7.138.221]:15631 "EHLO mail.tirnet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752099AbbCWJFF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 05:05:05 -0400
In-Reply-To: <1427077997.25985.59.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, 23. M=C3=A4rz 2015 03:33:17 schrieb Eric Dumazet:
> On Mon, 2015-03-23 at 01:57 +0100, Wolfgang Rosner wrote:
> > Are you ready to assist me on this track?
>
> First check if the problem is already solved, using this git tree ?
>
> http://git.kernel.org/cgit/linux/kernel/git/davem/net.git


Is it OK to use this 3.19 tag?
https://kernel.googlesource.com/pub/scm/linux/kernel/git/davem/net.git/=
+/v3.19


I see that head is v4.0-rc4
I'm afraid that this might break other things.
I think of aufs, which I need to get my clients nfsroot booted.
Without clients, I can't iperf the teql link.

I have to admit that I'm not the master of this git beast.
But I'm working my way, somehow...




Wolfgang Rosner
