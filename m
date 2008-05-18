From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] PHYLIB: Kconfig: Fix the dependency on S390
Date: Sun, 18 May 2008 13:12:35 -0500
Message-ID: <66B9C6DF-C81E-4281-8319-2D5470A05067@freescale.com>
References: <Pine.LNX.4.55.0805170647110.4049@cliff.in.clinika.pl>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:61349 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753024AbYERSM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 14:12:57 -0400
In-Reply-To: <Pine.LNX.4.55.0805170647110.4049@cliff.in.clinika.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 17, 2008, at 01:07, Maciej W. Rozycki wrote:

>
> PHYLIB was first marked as BROKEN on S390, then the enclosing menu  
> marked
> as non-S390, then the two dependencies merged with the conversion to
> menuconfig.  Reduce to non-S390.
>
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>

Acked-by: Andy Fleming <afleming@freescale.com>

