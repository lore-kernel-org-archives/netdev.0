From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: one pci_id missing in sky2 driver
Date: Sun, 1 Apr 2012 12:22:35 -0700
Message-ID: <20120401122235.714dab09@s6510.linuxnetplumber.net>
References: <4F763075.7040402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Xose Vazquez Perez <xose.vazquez@gmail.com>,
	David Miller <davem@davemloft.net>,
	Mirko Lindner <mlindner@marvell.com>,
	Hardy Bastian <hbastian@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36910 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752935Ab2DATWi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Apr 2012 15:22:38 -0400
In-Reply-To: <4F763075.7040402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 31 Mar 2012 00:15:17 +0200
Xose Vazquez Perez <xose.vazquez@gmail.com> wrote:

> hi,
> 
> taken from latest sk98lin marvell driver: 
> Date: 1/26/12
> Version: 10.92.1.3
> 
> 0x11AB,0x4382 /* Marvell Yukon 88E8079 Family PCI-E Gigabit Ethernet Controller */
> 
> -thanks-

I would like to use this opportunity to have the developers at Marvell, test and
submit this. They have the hardware (I don't) and often new chips require other
special tweaks.  Marvell expressed interest in taking over maintaining the sky2
driver, this would be a good first step.
