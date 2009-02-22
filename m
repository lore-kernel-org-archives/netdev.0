From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12749] New: no eth0 network device drivers
Date: Sat, 21 Feb 2009 18:00:58 -0800
Message-ID: <20090221180058.f37c71eb.akpm@linux-foundation.org>
References: <bug-12749-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, htmldeveloper@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49987 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751925AbZBVCBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2009 21:01:05 -0500
In-Reply-To: <bug-12749-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 21 Feb 2009 17:20:10 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12749

^^ additional info here

>            Summary: no eth0 network device drivers
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.29-rc5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: blocking
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: htmldeveloper@gmail.com
> 
> 
> Latest working kernel version:
> 
> 2.6.29-rc4
> 
> Earliest failing kernel version:
> 
> 2.6.29-rc5
> 
> Distribution: FC10

Strange.  I assume that something busted in your 2.6.28-rc5 .config
when you ran `make oldconfig' against the 2.6.29-rc4 .config.  But I'm
not seeing any suspicious Kconfig changes recently.


