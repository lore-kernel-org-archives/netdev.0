From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [UPDATED PATCH] ixgbe: fix vlan filtering
Date: Wed, 27 Aug 2008 05:18:12 -0400
Message-ID: <48B51BD4.7000303@garzik.org>
References: <20080827013004.5497.48208.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, stable@kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45221 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753883AbYH0JSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 05:18:16 -0400
In-Reply-To: <20080827013004.5497.48208.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> VLAN filtering is broken, due to reading the incorrect register for the VLAN filtering settings.  Fixed by reading/writing the correct register.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

applied


