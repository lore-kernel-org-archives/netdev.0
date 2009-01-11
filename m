From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading
 (-git7 is ok)
Date: Sun, 11 Jan 2009 14:19:35 -0800 (PST)
Message-ID: <20090111.141935.34892950.davem@davemloft.net>
References: <1231676698.25018.147.camel@macbook.infradead.org>
	<20090111.133929.57600645.davem@davemloft.net>
	<1231712154.25018.672.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, alessandro.suardi@gmail.com,
	jaswinderlinux@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34336
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752130AbZAKWTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 17:19:34 -0500
In-Reply-To: <1231712154.25018.672.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Sun, 11 Jan 2009 22:15:54 +0000

> On Sun, 2009-01-11 at 13:39 -0800, David Miller wrote:
> > 
> > For example, for mounting an NFS root using that device.... Oh, will I
> > need an initramfs for that once you pull the firmware-in-kernel
> > option?
> 
> Of course, we've been talking for ages about pulling the dhcp and
> nfsroot hacks from the kernel and requiring an initrd for that _anyway_,
> but that's a different issue...

It's not there now, so in the mean time....
