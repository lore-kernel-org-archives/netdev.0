From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 40732] New: atl2 NIC claims NO CARRIER after
 suspend/resume; rmmod + insmod fixes problem
Date: Tue, 23 Aug 2011 13:43:06 -0700
Message-ID: <20110823134306.827091ce.akpm@linux-foundation.org>
References: <bug-40732-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, dkg@fifthhorseman.net
To: netdev@vger.kernel.org, Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55450 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753418Ab1HWUnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 16:43:12 -0400
In-Reply-To: <bug-40732-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 8 Aug 2011 18:10:08 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=40732
> 
>                URL: http://bugs.debian.org/614622
>            Summary: atl2 NIC claims NO CARRIER after suspend/resume; rmmod
>                     + insmod fixes problem
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 3.0
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: dkg@fifthhorseman.net
>         Regression: No
> 
> 
> As reported in more detail at http://bugs.debian.org/614622, i have an atl2 NIC
> (03:00.0 Ethernet controller: Atheros Communications L2 Fast Ethernet (rev a0))
> which sometimes reports NO CARRIER after i suspend/resume.
> 
> This has been the case since 2.6.37 and it persists with 3.0 as well.  I'm
> using debian's 686 kernels.
> 

