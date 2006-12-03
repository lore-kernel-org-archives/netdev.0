From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 7621] New: 2.6.19 breaks IPv6
Date: Sat, 2 Dec 2006 19:20:09 -0800
Message-ID: <20061202192009.05277ebf.akpm@osdl.org>
References: <200612021923.kB2JNsLw018910@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasmin-bugs@pacifica.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:50313 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1759493AbWLCCUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Dec 2006 21:20:33 -0500
To: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
In-Reply-To: <200612021923.kB2JNsLw018910@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Sat, 2 Dec 2006 11:23:54 -0800 bugme-daemon@bugzilla.kernel.org wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=7621
> 
>            Summary: 2.6.19 breaks IPv6
>     Kernel Version: 2.6.19
>             Status: NEW
>           Severity: high
>              Owner: yoshfuji@linux-ipv6.org
>          Submitter: jasmin-bugs@pacifica.ch
> 
> 
> Vanille 2.6.19 oops'es at boot. With the patch from 
> http://marc.theaimsgroup.com/?l=linux-kernel&m=116485303623545&w=2 it boots 
> but IPv6 stopps working. I can't ping/traceroute any host. Network setup has 
> not changed.
> 
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
