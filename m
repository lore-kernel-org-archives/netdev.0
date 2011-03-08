From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 00/14][pull request] Intel Wired LAN Driver
 Updates
Date: Tue, 08 Mar 2011 11:11:37 -0800 (PST)
Message-ID: <20110308.111137.112604487.davem@davemloft.net>
References: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35294
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754377Ab1CHTK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 14:10:59 -0500
In-Reply-To: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon,  7 Mar 2011 18:24:54 -0800

> The following series contains fixes and cleanups for e1000e and ixgbe, as
> well as support for FCoE DDP in target mode for ixgbe.  In igb, added
> additional stats for OS2BMC feature.
> 
> The following are changes since commit 541ac7c9b30ee2ff84ad87f27e0bc069e143afb5:
>   bonding: COW before overwriting the destination MAC address
> 
> and are available in the git repository at:
>   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Pulled.

Please address the feedback given on the lack of docbook descriptions for
all of those fcoe device ops.
