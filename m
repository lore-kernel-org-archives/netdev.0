From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13548] New: DFE-580TX Quad Ethernet Doesn't
 work our system
Date: Mon, 22 Jun 2009 16:48:58 -0700
Message-ID: <20090622164858.0d34687f.akpm@linux-foundation.org>
References: <bug-13548-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, sinan.ulker@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39497 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751577AbZFVXs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 19:48:58 -0400
In-Reply-To: <bug-13548-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 15 Jun 2009 15:02:14 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13548
> 
>            Summary: DFE-580TX Quad Ethernet Doesn't work our system
>            Product: Networking
>            Version: 2.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: blocking
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: sinan.ulker@gmail.com
>         Regression: No
> 
> 
> Our system configuration is;
> 
> OS : Slackware 12.2
> Kernel : 2.6.29.4
> Ethernet : PCI D-Link DFE-580TX
> 

A tx timeout using 2.6.29's sundance.c.
