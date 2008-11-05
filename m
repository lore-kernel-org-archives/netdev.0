From: Chris Snook <csnook@redhat.com>
Subject: Re: Fwd: Network Core
Date: Wed, 05 Nov 2008 15:11:43 -0500
Message-ID: <4911FDFF.2060302@redhat.com>
References: <530d01580811050939q1c1dc52fra6fc2078d86d36e@mail.gmail.com> <530d01580811050940k2010ba3fpd0973f23e390c5e7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Diego ." <eljedi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40153 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756245AbYKEULA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 15:11:00 -0500
In-Reply-To: <530d01580811050940k2010ba3fpd0973f23e390c5e7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Diego . wrote:
> Hello!

Hi.

> I'm a kernel newbie.

Welcome.

> I'm trying to figure how hard it will be build some SMA protocol
> inside linux kernel. But i coud'nt  find any information about linux
> network layer/core. I started looking at source code inside net/ dir
> before asking here.

If you've never worked with kernel code before, it's extremely difficult.  I 
highly recommend that you get involved with development of existing kernel 
networking code before you try to make this leap.

> Could you point me to somewhere i can find some info about howto to
> port/create a network protocol to/on linux? ( i mean, some basic info
> like the one we can find with the fs layer. I'm not asking about a
> magic tutorial about how to port my protocol ). Or some basic network
> layer info.

There are a few O'Reilly books about the kernel networking stack, and anything 
written in the past few years should be recent enough for your purposes.  It 
would probably also be helpful to read articles (such as those on lwn.net) about 
new network stack features that have been added.  The commentary there will give 
you a general idea of the challenges you'll face, but you'll need to complement 
that with experience working with the network code.

-- Chris
