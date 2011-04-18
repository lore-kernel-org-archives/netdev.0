From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 33332] New: IC Plus Corp IP1000 Family Gigabit
 Ethernet and OpenSuSE (x86, x86_64)
Date: Mon, 18 Apr 2011 14:00:50 -0700
Message-ID: <20110418140050.2c194660.akpm@linux-foundation.org>
References: <bug-33332-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, gearge@gmail.com,
	Denis Kirjanov <dkirjanov@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56156 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751675Ab1DRVBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 17:01:44 -0400
In-Reply-To: <bug-33332-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 15 Apr 2011 16:32:20 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=33332
> 
>            Summary: IC Plus Corp IP1000 Family Gigabit Ethernet and
>                     OpenSuSE (x86, x86_64)
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.34.7-0.7-desktop
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: gearge@gmail.com
>         Regression: No
> 
> 
> I have an odd problem with my NIC; on both x86 and x86_64 OpenSuSE 11.3 I lose
> network connectivity with my gateway router, if heavy downloading is evolved
> (e.g. downloading a large file over HTTP or any activity - large or small - on
> bittorrent). I have no limitations on my ISP side and the router is working
> fine. I even upgraded to the latest firmware from my wireless router's vendor
> and installed third party firmware, but the problem remains. While I lose
> connectivity on the wired network segment (my PC is directly connected to the
> router), the wireless segment continues to operate. What's even more odd, I
> have no networking issues while watching streaming media - normal or higher
> quality.
> 
> Information about my network card:
> 
> 06:01.0 Ethernet controller [0200]: Sundance Technology Inc / IC Plus Corp
> IP1000 Family Gigabit Ethernet [13f0:1023] (rev 41)
> 
> 1: None 00.0: 10701 Ethernet
> [Created at net.124]
> Unique ID: usDW.ndpeucax6V1
> Parent ID: rBUF.H29BqU8ALB5
> SysFS ID: /class/net/eth0
> SysFS Device Link: /devices/pci0000:00/0000:00:1e.0/0000:06:01.0
> Hardware Class: network interface
> Model: "Ethernet network interface"
> Driver: "Sundance Technology IPG Triple-Speed Ethernet"
> Driver Modules: "ipg"
> Device File: eth0
> HW Address:
> Link detected: yes
> Config Status: cfg=new, avail=yes, need=no, active=unknown
> Attached to: #31 (Ethernet controller)
> 
> Please assist in resolving this issue.
> 

