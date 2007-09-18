From: David Miller <davem@davemloft.net>
Subject: Re: bnx2 dirver's firmware images
Date: Tue, 18 Sep 2007 13:08:10 -0700 (PDT)
Message-ID: <20070918.130810.78161599.davem@davemloft.net>
References: <46F01BDE.6020902@zytor.com>
	<20070918.122034.83625273.davem@davemloft.net>
	<46F02688.8030507@zytor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, vda.linux@googlemail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: hpa@zytor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59653
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754951AbXIRUIN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 16:08:13 -0400
In-Reply-To: <46F02688.8030507@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "H. Peter Anvin" <hpa@zytor.com>
Date: Tue, 18 Sep 2007 12:27:04 -0700

> Well, what I was referring to here, of course, was the initramfs
> integrated in the kernel image, so it all comes out of the kernel build
> tree and produces a single bootable image.  The fact that part of it
> contains userspace code is in that way invisible.
> 
> That was kind of the point here, and the only reason for pushing klibc
> into the kernel build tree at all.  Under the "distros use external
> initrd anyway" school of thought, whatever libc used for that can be
> external anyway.

Sounds good to me :)
