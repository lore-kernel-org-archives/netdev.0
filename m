From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12228] New: D-Link 530 TX Rev. C2 not working
Date: Mon, 15 Dec 2008 00:18:16 -0800
Message-ID: <20081215001816.79f1332b.akpm@linux-foundation.org>
References: <bug-12228-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, infos@widelinkpc.be
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41640 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752055AbYLOISt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 03:18:49 -0500
In-Reply-To: <bug-12228-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 15 Dec 2008 00:00:56 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12228
> 
>            Summary: D-Link 530 TX Rev. C2 not working
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.27.X
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: infos@widelinkpc.be
> 
> 
> Latest working kernel version: 2.6.24 and 2.6.25
> Earliest failing kernel version: 2.6.27.X
> Distribution: Actually Ubuntu 8.10 Deskstop (32 bit) and Fedora 10 Deskstop (32
> bit)
> Hardware Environment: Always the same since many years to test different
> distributions: Asus P4P800 SE, GeForce 7800 GS in AGP, 2 x 1 GB DDR 1 Kingmax.
> Software Environment: just TeamSpeak Server on Ubuntu 8.10 and CCSM (Compiz
> Configurator). Fedora nothing more than original package. Just update from
> Fedora repositories.
> Problem Description: in the past this hardware working fine with previous
> version of distribution. Since the last version, my nertwork card doesn't work.
> I'm not a hacker, just want help you.
> 
> Steps to reproduce: I have tested 2 distributions with install on my hardrive.
> Not working. I change hardrive to see on Windows (whith drivers of course) and
> my card working fine. The hardware working fine, but I think there is a problem
> with Linux driver. I haven't problem to connect internet with the onboard chip
> Marvell Yukon.
> 
> I hope it's not a bug from Network Manager, but I think no.
> 

ok, I give up ;)  Which device driver does that card use?
