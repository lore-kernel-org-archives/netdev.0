From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12484] New: Kernel panic 1gb lan connection
Date: Mon, 26 Jan 2009 23:09:02 -0800
Message-ID: <20090126230902.85af7ea9.akpm@linux-foundation.org>
References: <bug-12484-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: nice10150@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34539 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751750AbZA0HJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 02:09:23 -0500
In-Reply-To: <bug-12484-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 19 Jan 2009 02:10:36 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12484
> 
>            Summary: Kernel panic 1gb lan connection
>            Product: Other
>            Version: 2.5
>      KernelVersion: 2.6.27
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Modules
>         AssignedTo: other_modules@kernel-bugs.osdl.org
>         ReportedBy: nice10150@gmail.com
> 
> 
> Latest working kernel version:?
> Earliest failing kernel version:2.6.27
> Distribution: Fedora 10, Ubuntu, etc...
> Hardware Environment: Asus P4S800D-E Delux mother board with Marvell Yukon
> giga-lan chipset.
> Software Environment:
> Problem Description: The combination of Marvel 1gb Lan connection and kernel
> 2.6.27 generates a kernel panic at boot. The identical setup connected to a
> 10/100 network boots regular.
> 
> Steps to reproduce: Boot system equipped with (Asus motherboard) Marvell Yukon
> network chipset connected to a 1gb Lan enabled network.
> 

We'd like a bit more information about the panic please.

Ideally, set up a serial console and capture the entire kernel output. 
If that is not practical, perhaps a digital photograph of the screen? 
Setting the screen into 50-row mode beforehand is often useful.

Worst-case, just type it all in again :(  Usually all the hexadecimal
numbers can just be omitted when doing this.

Thanks.

