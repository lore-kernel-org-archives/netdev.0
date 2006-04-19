From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 6414] New: sky2  problem
Date: Wed, 19 Apr 2006 15:55:48 -0700
Message-ID: <20060419155548.4e0b39f2.akpm@osdl.org>
References: <200604192240.k3JMel3r013309@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chenzhq@126.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:8395 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751311AbWDSWxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2006 18:53:32 -0400
To: bugme-daemon@bugzilla.kernel.org
In-Reply-To: <200604192240.k3JMel3r013309@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bugme-daemon@bugzilla.kernel.org wrote:
>
> http://bugzilla.kernel.org/show_bug.cgi?id=6414
> 
>            Summary: sky2  problem
>     Kernel Version: 2.6.15, 2.6.16,2.6.17
>             Status: NEW
>           Severity: high
>              Owner: jgarzik@pobox.com
>          Submitter: chenzhq@126.com
> 
> 
> Distribution: Fedora Core 5, kernel-2.6.15, update to kernel-2.6.16-9, or
> kernel-2.6.17
> Hardware Environment: Toshiba M45-S265 laptop, Marvell Yukon  Marvell Technology
> Group Ltd. 88E8036 PCI-E Fast Ethernet Controller
>  
> Problem Description: cannot scp large file from my computer to other computer on
> my laptop. or scp large file from other computer to my laptop on other computer.
> even I can't fish/ftp large file .
> it showed me stalled. all the other program can't work. I have to /sbin/service
> newwork restart . then other program can work.
> 

Thanks.

Are you able to identify any earlier kernel version which didn't have this
problem?

