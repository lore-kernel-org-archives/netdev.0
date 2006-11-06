From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.18] defxx: Big-endian hosts support
Date: Mon, 06 Nov 2006 03:13:22 -0500
Message-ID: <454EEEA2.1050301@pobox.com>
References: <Pine.LNX.4.64N.0610231330190.4426@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:13443 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1423586AbWKFIN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 03:13:28 -0500
To: "Maciej W. Rozycki" <macro@linux-mips.org>
In-Reply-To: <Pine.LNX.4.64N.0610231330190.4426@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Maciej W. Rozycki wrote:
>  The PDQ DMA engine requires a different byte-swapping mode for big-endian 
> hosts; also the MAC address which is read from a register through PIO has 
> to be byte-swapped.  These changes have been verified with DEFPA-DC (PCI) 
> boards and a Broadcom BCM91250A (MIPS CPU based) host.
> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>

applied


