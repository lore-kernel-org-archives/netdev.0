From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [GIT PULL] Support for Cadence GEM in the MACB driver
Date: Wed, 23 Nov 2011 21:14:11 +0000
Message-ID: <201111232114.12124.arnd@arndb.de>
References: <20111121100020.GB7314@totoro>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Jean-Christophe PLAGNIOL-VILLARD" <plagnioj@jcrosoft.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	davem@davemloft.net
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:64828 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753248Ab1KWVOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 16:14:21 -0500
In-Reply-To: <20111121100020.GB7314@totoro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 21 November 2011, Jamie Iles wrote:
> Hi Arnd,
> 
> Please consider pulling the patches to add support for Cadence GEM to 
> the MACB driver.  These have been ready to go for a little while but got 
> held up with the rename of Ethernet drivers in the last merge window.  
> It would be great if we can get some exposure in -next for a little 
> while before the next merge window.

Hi Jamie,

I was actually meaning to pull these in time for 3.2, but for some reason
this got dropped on the floor when I was travelling just before
and during the merge window.

Anyway, I've pulled them into the next/driver branch of the arm-soc tree
now. Thanks for your patience!

	Arnd
