From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/3] macvlan: allow in-kernel modules to create and manage macvlan devices
Date: Thu, 3 Dec 2009 21:28:51 +0000
Message-ID: <200912032128.51929.arnd@arndb.de>
References: <4B17C107020000C70007C8CE@soto.provo.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org,
	alacrityvm-devel@lists.sourceforge.net, kaber@trash.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Patrick Mullaney" <pmullaney@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:54043 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791AbZLCVaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 16:30:03 -0500
In-Reply-To: <4B17C107020000C70007C8CE@soto.provo.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 03 December 2009 20:45:43 Patrick Mullaney wrote:
> I hope I didn't confuse things by posting:
> 
> netdevice: provide common routine for macvlan and vlan operstate
> management
> 
> again. I offered to send that out patched against net-next-2.6 last
> week and I just got back to following up. I'm fine with you rolling
> them into your series too.

Not at all, thanks for sending that yourself! You did miss the Acked-by
lines from Patrick McHardy and myself though, they should have been
part of your resend. I'll add give you another one then.

	Arnd <><
