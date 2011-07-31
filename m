From: Lennert Buytenhek <kernel@wantstofly.org>
Subject: Re: [net-next v2 26/71] xscale: Move the Intel XScale IXP drivers
Date: Sun, 31 Jul 2011 10:38:53 +0200
Message-ID: <20110731083853.GB912@wantstofly.org>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1312082850-24914-27-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, Krzysztof Halasa <khc@pm.waw.pl>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:51542 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421Ab1GaIi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2011 04:38:57 -0400
Content-Disposition: inline
In-Reply-To: <1312082850-24914-27-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 30, 2011 at 08:26:45PM -0700, Jeff Kirsher wrote:

> Move the Intel XScale IXP drivers into drivers/net/ethernet/xscale/
> and make the necessary Kconfig and Makefile changes.
> 
> CC: Krzysztof Halasa <khc@pm.waw.pl>
> CC: Lennert Buytenhek <kernel@wantstofly.org>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> [...]
>
>  rename drivers/net/{ => ethernet/xscale}/ixp2000/Kconfig (76%)

This is pretty deeply nested, but OK.

Acked-by: Lennert Buytenhek <kernel@wantstofly.org>
