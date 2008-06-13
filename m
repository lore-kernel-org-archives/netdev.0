From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10903] New: ssh connections hang with
 2.6.26-rc5
Date: Fri, 13 Jun 2008 02:58:04 -0700
Message-ID: <20080613025804.4913de04.akpm@linux-foundation.org>
References: <bug-10903-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, didier@raboud.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34335 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753866AbYFMJ6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 05:58:39 -0400
In-Reply-To: <bug-10903-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 13 Jun 2008 02:39:17 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10903
> 
>            Summary: ssh connections hang with 2.6.26-rc5
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.26-rc5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: didier@raboud.com
> 
> 
> Latest working kernel version: 2.6.25-2
> Earliest failing kernel version: 2.6.26-rc5
> Distribution: Debian (Lenny + Sid)
> Hardware Environment: amd64 (Dell Latitude D630)
> Software Environment: KDE
> Problem Description:
> 
> With kernel version 2.6.26-rc5, the ssh connections to remote servers randomly
> hang (no error message). No amelioration despite the activation of
> "ServerAliveInterval" on both sides.
> 
> Steps to reproduce:
> 
> Connect to a remote ssh server and do some stuff. After some time, the
> connection will hang.
> 
> Please ask for details.
> 

