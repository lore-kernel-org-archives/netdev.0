From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RESEND] [NET-NEXT PATCH 2/3] e1000e: add support for 82567LM-3
 and	82567LF-3 (ICH10D) parts
Date: Wed, 03 Sep 2008 10:07:38 -0400
Message-ID: <48BE9A2A.1020904@garzik.org>
References: <20080827013611.5716.7376.stgit@jtkirshe-mobile.jf.intel.com> <20080827013639.5716.27200.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, andy@greyhouse.net,
	Bruce Allan <bruce.w.allan@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43687 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751398AbYICOHl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 10:07:41 -0400
In-Reply-To: <20080827013639.5716.27200.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Add support for new LOM devices on the latest generation ICHx platforms.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/e1000e/defines.h |    2 +
>  drivers/net/e1000e/e1000.h   |    3 +
>  drivers/net/e1000e/ethtool.c |   22 +++++-
>  drivers/net/e1000e/hw.h      |    3 +
>  drivers/net/e1000e/ich8lan.c |  154 +++++++++++++++++++++++++++++++++++++++---
>  drivers/net/e1000e/netdev.c  |   25 +++++++
>  drivers/net/e1000e/phy.c     |   85 +++++++++++++++++++++++
>  7 files changed, 280 insertions(+), 14 deletions(-)

applied


