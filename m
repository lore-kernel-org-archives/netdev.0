From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.32-rc6] drivers/net: ks8851_mll ethernet network
 driver -resubmit
Date: Fri, 20 Nov 2009 13:55:12 -0800 (PST)
Message-ID: <20091120.135512.230579850.davem@davemloft.net>
References: <C43529A246480145B0A6D0234BDB0F0D02129B@MELANITE.micrel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	shemminger@vyatta.com, greg@kroah.com
To: David.Choi@Micrel.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45568
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755462AbZKTVyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 16:54:54 -0500
In-Reply-To: <C43529A246480145B0A6D0234BDB0F0D02129B@MELANITE.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Choi, David" <David.Choi@Micrel.Com>
Date: Thu, 19 Nov 2009 17:34:30 -0800

> This patch is for ks8851 16bit MLL Ethernet network device driver in order to 
> fix bugs and to enhance functions. This resubmit removes a printk statement causing
> the compile warning in 64bit processors.

Applied.

>>From 	: David J. Choi <david.choi@micrel.com>

Please fix how this is emiited in your emails.  GIT won't pick
it up to use this as the author information unless it is
formatted correctly.  That leading '>' character and the
TAB between "From" and ":" need to go away.

I edited it out by hand this time.

Thanks.
