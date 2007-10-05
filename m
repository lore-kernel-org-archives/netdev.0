From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 9124] New: Netconsole race crashed the system
Date: Thu, 04 Oct 2007 22:22:19 -0700 (PDT)
Message-ID: <20071004.222219.02300073.davem@davemloft.net>
References: <470592E8.7080809@oracle.com>
	<20071004202414.0f1eddb7@freepuppy.rosehill>
	<4705B602.6090306@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, akpm@linux-foundation.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: tina.yang@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56996
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751425AbXJEFWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 01:22:20 -0400
In-Reply-To: <4705B602.6090306@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tina Yang <tina.yang@oracle.com>
Date: Thu, 04 Oct 2007 20:56:50 -0700

>     Yes, it's RHEL5 2.6.18-8.  Attached is the 2.6.9-42 version that 
> doesn't have 802.11 and
>     crashed at the same spot - netdevice.h:888.  Also crashed are 
> 2.6.23-rc2 and rc4.

2.6.9-42 is, again, a vendor modified kernel.

Please show the crash information against vanilla upstream kernels if
you want us to take a serious look at this, thanks a lot.
