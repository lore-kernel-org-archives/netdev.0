From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12392] New: Can't change mac addr
Date: Fri, 9 Jan 2009 10:36:09 -0800
Message-ID: <20090109103609.04b3b538.akpm@linux-foundation.org>
References: <bug-12392-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44211 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753653AbZAISgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 13:36:23 -0500
In-Reply-To: <bug-12392-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri,  9 Jan 2009 05:30:07 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12392
> 
>            Summary: Can't change mac addr
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: >=2.6.28 fail woks <=2.6.28-rc9-git1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: diabelx@gmail.com
> 
> 
> Latest working kernel version: 2.6.28-rc9-git1
> Earliest failing kernel version: >=2.6.28

A regression.

> Distribution:gantoo
> Hardware Environment: 04:05.0 Ethernet controller: Realtek Semiconductor Co.,
> Ltd. RTL-8139/8139C/8139C+ (rev 10)
> Software Environment: ifconfig,macchanger
> Problem Description:
> Can't change mac address, Any attempt to change the address ends in an error :
> RTNETLINK answers: Operation not supported
> ERROR: Can't change MAC: interface up or not permission: Operation not
> supported
> 
> 
> Steps to reproduce:

