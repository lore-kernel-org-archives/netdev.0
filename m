From: Michael Guntsche <mike@it-loops.com>
Subject: Re: [BUG] 2.6.30-rc4: Kernel BUG under network load with gianfar
Date: Fri, 22 May 2009 19:59:01 +0200
Message-ID: <D8767624-24E6-49B7-BC0A-084435C8DDAC@it-loops.com>
References: <50F164E7-D247-4FD6-B41B-BDAA8681166B@it-loops.com> <20090520214734.GA11277@mail.wantstofly.org> <20090521.152439.79009648.davem@davemloft.net> <9E304569-5828-403D-B4B0-845D8F0D6B95@it-loops.com> <C6E445A9-0CE7-4270-848E-6FB34B3271D5@freescale.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, buytenh@wantstofly.org,
	linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:47360
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751824AbZEVR7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 13:59:06 -0400
In-Reply-To: <C6E445A9-0CE7-4270-848E-6FB34B3271D5@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 22, 2009, at 19:18, Andy Fleming wrote:

> I'm working (admittedly fairly slowly) on a patch that resets the  
> pointers so they don't get moved twice.  That way we can continue to  
> benefit from recycling the error skbs.

Ok, thanks for the information. Just tell me when you have a patch  
ready for testing, since it's fairly easy for me to reproduce this  
here with my setup. I'll keep Lennard's patch in the meantime.

Kind regards,
Michael
