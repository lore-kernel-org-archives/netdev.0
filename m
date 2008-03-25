From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10323] New: panic using bridging on linus
 kernel 2.6.24-rc6
Date: Tue, 25 Mar 2008 12:56:33 -0700
Message-ID: <20080325125633.ec1573af.akpm@linux-foundation.org>
References: <bug-10323-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45026 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752676AbYCYT5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 15:57:07 -0400
In-Reply-To: <bug-10323-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Mar 2008 11:40:32 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10323
> 
>            Summary: panic using bridging on linus kernel 2.6.24-rc6
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24-rc6
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: andy@greyhouse.net
>                 CC: nhorman@tuxdriver.com
> 
> 
> Reproducer:
> 1.  Boot latest linus git tree (2.6.24-rc6).

This should have been 2.6.25-rc6.  It looks like a post-2.6.24 regression -
Andy is investigating.

I didn't cc bugme-daemon because this one is already being worked on via
bugzilla, not via email.

