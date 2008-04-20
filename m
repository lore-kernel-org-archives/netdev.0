From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10487] New: NIC (forcedeth) doesn't work with
 suspend (S3)
Date: Sun, 20 Apr 2008 15:21:35 -0700
Message-ID: <20080420152135.d2c45887.akpm@linux-foundation.org>
References: <bug-10487-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>
To: fragabr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49841 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752842AbYDTWVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 18:21:22 -0400
In-Reply-To: <bug-10487-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).


> On Sun, 20 Apr 2008 00:06:07 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=10487
> 
>            Summary: NIC (forcedeth) doesn't work with suspend (S3)
>            Product: Power Management
>            Version: 2.5
>      KernelVersion: 2.6.25
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Hibernation/Suspend
>         AssignedTo: power-management_other@kernel-bugs.osdl.org
>         ReportedBy: fragabr@gmail.com
> 
> 
> Latest working kernel version: 2.6.25

No, that's not right.  Please tell us the latest version of the kernel
which worked OK.

> Earliest failing kernel version: all
> Distribution: Linux from scratch
> Hardware Environment: Athlon64 x2 (x86-64), Asus M2N-E
> Software Environment: 
> Problem Description:
> 
> When I use s2ram to suspend to ram, everything works, except the network
> (forcedeth) that doesn't come back from suspend. So I have to reboot the
> machine.
> 
> Steps to reproduce:
> 
> 1) s2ram
> 
> 2) then wake up from suspend
> 
> 3) network isn't working anymore
> 
> 

