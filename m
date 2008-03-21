From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [AX25] kernel panic
Date: Fri, 21 Mar 2008 01:28:47 +0100
Message-ID: <20080321002846.GA25568@ami.dom.local>
References: <47DF9D21.20807@free.fr> <20080318212531.GA2031@electric-eye.fr.zoreil.com> <47E0C261.3000106@free.fr> <47E17E2E.9050105@free.fr> <20080320073021.GA4037@ff.dom.local> <47E2EC1B.9070405@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@o2.pl>
To: Bernard Pidoux <bpidoux@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.191]:51041 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858AbYCUAWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 20:22:12 -0400
Received: by mu-out-0910.google.com with SMTP id i10so1629559mue.5
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2008 17:22:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <47E2EC1B.9070405@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 20, 2008 at 11:58:35PM +0100, Bernard Pidoux wrote:
...
> I recompiled the kernel after turning off the above options.
> However there is still a kernel panic documented below.
> Does it help ?

I wanted to see something more on the stack than lockdep's code only.
Will see... It seems some memory debugging is still on and doing this
poisoning with '6b', but I can't check now what it is. (Sometimes this
could omit some warnings).

Thanks,
Jarek P.
