From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RESEND] [NET-NEXT PATCH 1/3] e1000e: add support for the 82567LM-4
 device
Date: Wed, 03 Sep 2008 10:07:27 -0400
Message-ID: <48BE9A1F.6070008@garzik.org>
References: <20080827013611.5716.7376.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, andy@greyhouse.net,
	Bruce Allan <bruce.w.allan@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43676 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754011AbYICOHb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 10:07:31 -0400
In-Reply-To: <20080827013611.5716.7376.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Enable PCI device ID for a new combination of MAC and PHY already supported
> in the driver.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/e1000e/hw.h      |    1 +
>  drivers/net/e1000e/ich8lan.c |    1 +
>  drivers/net/e1000e/netdev.c  |    1 +
>  3 files changed, 3 insertions(+), 0 deletions(-)

applied


