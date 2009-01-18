From: Sitsofe Wheeler <sitsofe@yahoo.com>
Subject: Re: [atl2] warn_slowpath in dev_watchdog
Date: Sun, 18 Jan 2009 09:46:31 -0800 (PST)
Message-ID: <789828.48438.qm@web110610.mail.gq1.yahoo.com>
References: <gkt97e$ti0$1@ger.gmane.org> <20090117194045.649f55a0@osprey.hogchain.net> <767752.95325.qm@web110601.mail.gq1.yahoo.com> <20090118095231.2c73c448@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, Chris Snook <csnook@redhat.com>,
	jie.yang@atheros.com, atl1-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Jay Cliburn <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web110610.mail.gq1.yahoo.com ([67.195.13.201]:32832 "HELO
	web110610.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933781AbZARRqc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jan 2009 12:46:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Jay Cliburn <jcliburn@gmail.com>
> 
> I'd like to see the full dmesg that includes the warning, if you can
> obtain it next time it occurs.  Meanwhile, please see if this patch
> helps.

I forgot to mention, looking back I see that once the link disappeared 
(while the cable was still plugged in) on the router but partially came 
back (the the link reappears but the router doesn't serve DHCP leases 
or seemingly route packets) booting new kernels from cold would 
show the problem while network manager was trying to obtain a 
DHCP lease.

I will test your patch the next time that this happens (but this may be 
a while).



      
