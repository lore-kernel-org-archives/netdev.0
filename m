From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 4/5] igb: clean up a stray fake netdev code left in rx
 path
Date: Wed, 03 Sep 2008 10:09:36 -0400
Message-ID: <48BE9AA0.50608@garzik.org>
References: <20080826112503.15627.3855.stgit@jtkirshe-mobile.jf.intel.com> <20080826112510.15627.75540.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43755 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754549AbYICOJj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 10:09:39 -0400
In-Reply-To: <20080826112510.15627.75540.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> Remove code that was in place to support fake netdev
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/igb/igb_main.c |    5 -----
>  1 files changed, 0 insertions(+), 5 deletions(-)

applied


