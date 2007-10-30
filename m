From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 4/4] ixgbe: minor sparse fixes
Date: Tue, 30 Oct 2007 14:33:05 -0400
Message-ID: <472778E1.4060101@garzik.org>
References: <20071029174605.25245.15294.stgit@localhost.localdomain> <20071029174624.25245.22619.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60786 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756514AbXJ3SdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 14:33:07 -0400
In-Reply-To: <20071029174624.25245.22619.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> From: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> Make strings const if possible, and fix includes so forward definitions
> are seen.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/ixgbe/ixgbe.h       |    2 +-
>  drivers/net/ixgbe/ixgbe_82598.c |    3 +--
>  drivers/net/ixgbe/ixgbe_main.c  |    9 +++++----
>  3 files changed, 7 insertions(+), 7 deletions(-)

applied 1-4

