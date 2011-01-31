From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 2011-01-30
Date: Sun, 30 Jan 2011 22:19:32 -0800 (PST)
Message-ID: <20110130.221932.260090087.davem@davemloft.net>
References: <1296389504-11208-1-git-send-email-sven@narfation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sven@narfation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46452
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752037Ab1AaGS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 01:18:57 -0500
In-Reply-To: <1296389504-11208-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>
Date: Sun, 30 Jan 2011 13:11:40 +0100

> Hi,
> 
> I would like to propose following patches for net-2.6.git/2.6.38. These are
> important fixes for kernel oopses/memory leaks. I already send this exact same
> request in 201101301036.57928.sven@narfation.org were you requested a new patch
> series posting.
> 
> I cannot reduce the number of fixes any more because it makes no sense to fix
> one Oops and leave the other one open. I've already removed the fixes for the
> protocol implementation errors from the first patchset.
> 
> The following changes since commit aa0adb1a85e159cf57f0e11282bc6c9e3606a5f3:
> 
>   batman-adv: Use "__attribute__" shortcut macros (2011-01-16 03:25:19 +0100)
> 
> are available in the git repository at:
>   git://git.open-mesh.org/ecsv/linux-merge.git batman-adv/merge-oopsonly

Pulled, thanks a lot.
