From: Tony Lill <ajlill@ajlc.waterloo.on.ca>
Subject: Re: [Bugme-new] [Bug 10996] New: 2.6.25 kernels spew SKB BUG:
 Invalid truesize when using ipsec/openswan
Date: Mon, 30 Jun 2008 17:58:34 -0400
Message-ID: <200806302158.m5ULwYfA025042@freevo.ajlc.waterloo.on.ca>
References: <bug-10996-10286@http.bugzilla.kernel.org/>
	<20080627164038.3338fb39.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ajlill.sentex.ca ([64.7.134.25]:44463 "EHLO
	freevo.ajlc.waterloo.on.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1762898AbYF3WHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 18:07:20 -0400
In-Reply-To: <20080627164038.3338fb39.akpm@linux-foundation.org> (Andrew
 Morton's message of "Fri, 27 Jun 2008 16:40:38 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> writes:

> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> On Fri, 27 Jun 2008 16:37:22 -0700 (PDT)
> bugme-daemon@bugzilla.kernel.org wrote:
>
>> http://bugzilla.kernel.org/show_bug.cgi?id=10996
>> 
>>            Summary: 2.6.25 kernels spew SKB BUG: Invalid truesize when using
>>                     ipsec/openswan
>>            Product: Networking
>>            Version: 2.5
>>      KernelVersion: Linux version 2.6.25.9 (ajlill@ds) (gcc version 3.4.6
>>                     (Debian 3.
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: low
>>           Priority: P1
>>          Component: IPV4
>>         AssignedTo: shemminger@linux-foundation.org
>>         ReportedBy: ajlill@ajlc.waterloo.on.ca
>> 
>> 
>> Latest working kernel version: 2.6.24.4
>> Earliest failing kernel version:2.6.25.4
>
> These two lines are contradictory.  Please clarify.

There were no messages when I was running 2.6.24.4, and there were
when I switched to 2.6.25.4. Now I haven't tried any kernels between
those, but I suspect it's a problem with the entire 2.6.25 branch.

