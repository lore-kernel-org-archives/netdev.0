From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [git patches] net driver fixes for 2.6.28-rc
Date: Mon, 03 Nov 2008 17:59:26 -0500
Message-ID: <490F824E.3070809@garzik.org>
References: <20081103205121.GA6005@havoc.gtf.org> <B9DCBB9E-9DE3-4114-9FFC-7A7C0C3DA920@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59361 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752314AbYKCW7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 17:59:32 -0500
In-Reply-To: <B9DCBB9E-9DE3-4114-9FFC-7A7C0C3DA920@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcel Holtmann wrote:
> Hi Jeff,
> 
>> Please pull from 'davem-fixes' branch of
>> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git 
>> davem-fixes
>>
>> to receive the following updates:
>>
>> drivers/net/Kconfig                |   18 +++++++++++++++---
>> drivers/net/fs_enet/fs_enet-main.c |    6 ++++--
>> drivers/net/mv643xx_eth.c          |    9 ++++++---
>> 3 files changed, 25 insertions(+), 8 deletions(-)
> 
> are you also queuing patches for drivers/net/usb/hso.c, because the 
> current state of that driver is fully broken. It oopses and shows up 
> with a WLAN RFKILL switch instead of WWAN. Also it has some weird 
> disconnect race with the TTY layer. Some patches have been posted, but 
> seems that nobody has picked them up so far.

Last patch sent me was sent on 9/16 by Denis Joseph Barrow; I replied 
and never received a response after that.

Patches welcome...

I don't see any hso patches on
http://patchwork.ozlabs.org/project/netdev/list/ nor in my inbox, so I'm 
guessing that no one sent me or netdev any hso patches.

	Jeff


