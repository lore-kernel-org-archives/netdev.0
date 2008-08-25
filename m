From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: [PATCH netdev-2.6] jme: JMicron Gigabit Ethernet Driver (Resend2)
Date: Mon, 25 Aug 2008 09:54:51 +0800
Message-ID: <20080825015014.M78106@cooldavid.org>
References: <48B12183.50601@cooldavid.org>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=big5
Cc: Ethan <ethanhsiao@jmicron.com>, akeemting <akeem@jmicron.com>,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 220-133-139-86.HINET-IP.hinet.net ([220.133.139.86]:40658 "EHLO
	cooldavid.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753413AbYHYByy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Aug 2008 21:54:54 -0400
In-Reply-To: <48B12183.50601@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 24 Aug 2008 16:53:23 +0800, Guo-Fu Tseng wrote
> Dear Jeff:
> 
> New patch for JMicron Gigabit Ethernet driver has been made again.
> 
> Modified according to Stephen's suggestion:
> 	* Correctly use of __u32, and u32 data type.
> 	* Move DEVICE ID from global include/linux/pci_ids.h to jme.h
> 
> The patch is also available at:
> http://cooldavid.org/download/jme.netdev-2.6.20080824.2.patch
> 
> Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
> ---
Hi Jeff:

I've found that after some modification, ACPI resume will fail,
although I seems to found the cause and fixed it. But I decided
to perform more test after the modification. After the test I'll
send another patch. Please hold this patch for a while.

Sorry for the noise that have been made.

