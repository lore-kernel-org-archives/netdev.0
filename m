From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 12/14] e1000e: store EEPROM version number to
 prevent unnecessary NVM reads
Date: Fri, 21 Nov 2008 17:00:29 -0800 (PST)
Message-ID: <20081121.170029.107459148.davem@davemloft.net>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
	<20081121190221.32313.93452.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44111
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757964AbYKVBAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 20:00:30 -0500
In-Reply-To: <20081121190221.32313.93452.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 21 Nov 2008 11:02:21 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Rather than reading the NVM to get the EEPROM version number everytime the
> ethool get_drvinfo function is called, read it once during probe and save
> it for future reference.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
