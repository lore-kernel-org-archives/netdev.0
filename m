From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8996] New: atl1 driver cause kernel oops IF
 ram > 4Gyte and a lot of network load
Date: Sat, 8 Sep 2007 17:36:21 -0700
Message-ID: <20070908173621.be09458d.akpm@linux-foundation.org>
References: <bug-8996-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Jay Cliburn <jacliburn@bellsouth.net>
To: micheleschi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46060 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755288AbXIIAg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2007 20:36:26 -0400
In-Reply-To: <bug-8996-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat,  8 Sep 2007 13:08:37 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8996
> 
>            Summary: atl1 driver cause kernel oops IF ram > 4Gyte and a lot
>                     of network load
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.22
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: micheleschi@gmail.com
> 
> 
> Most recent kernel where this bug did not occur:
> Distribution:
> Hardware Environment:
> Software Environment:
> Problem Description:
> 
> Steps to reproduce:
> 
> 

(switching to email.  Please respond via emailed reply-to-all, not
via the bugzilla UI, thanks).

We'd really need to see the kernel log output from that oops, please.
