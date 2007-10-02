From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9112] New: tcpdump on a syncppp interface
 panics kernel
Date: Tue, 2 Oct 2007 11:04:50 -0700
Message-ID: <20071002110450.27db939b.akpm@linux-foundation.org>
References: <bug-9112-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, mattilinnanvuori@yahoo.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:43517 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752887AbXJBSEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 14:04:55 -0400
In-Reply-To: <bug-9112-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue,  2 Oct 2007 08:00:47 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9112
> 
>            Summary: tcpdump on a syncppp interface panics kernel
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.22.9
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: mattilinnanvuori@yahoo.com
> 
> 
> Most recent kernel where this bug did not occur: 2.4.30?
> Hardware Environment: Motherboard PMB-532LF
> Software Environment: a private driver depending on syncppp
> Problem Description: tcpdump on a interface registered by a driver derived from
> syncppp panics kernel.
> 

Well that's cute.  Who maintains syncppp?
