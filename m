From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 39602] New: atl1c constantly freezeon acer one
 522
Date: Wed, 27 Jul 2011 15:59:24 -0700
Message-ID: <20110727155924.8dc95747.akpm@linux-foundation.org>
References: <bug-39602-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, Jie Yang <jie.yang@atheros.com>,
	eric.valette@free.fr
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56231 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753031Ab1G0W73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2011 18:59:29 -0400
In-Reply-To: <bug-39602-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 19 Jul 2011 16:24:31 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=39602
> 
>            Summary: atl1c constantly freezeon  acer one 522
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 3.0.0-rc7-git5 AMD64 arch
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: eric.valette@free.fr
>         Regression: No
> 
> 
> When I have atl1c module loaded along with ath9k for WiFi my acer one 522
> freeze without even emitting a gasp. Removing the module before it freezes,
> make the netop works for hours. Unplugin the thernet cacle while on ethernet
> also cause the system to hang.
> 
> there are already plenty of bug reports regarding this triver which I know is
> experimental like
> <http://www.manticore-projects.com/content/en/software/guides/aspire522.htm>
> but also <https://bugs.launchpad.net/ubuntu/+source/linux/+bug/512764> 
> 
> The bug seems to have appeared on many different hardware. Probably related to
> intr management but have no way to provide any traces as reset button for 5s is
> needed.
> 
> Can provide dmesg, dmidecode and so on. Just ask.
> 

