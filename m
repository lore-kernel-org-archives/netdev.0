From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [net-next v2 56/71] macb: Move the Atmel driver
Date: Mon, 1 Aug 2011 15:41:42 +0100
Message-ID: <20110801144142.GD2610@pulham.picochip.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1312082850-24914-57-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, Nicolas Ferre <nicolas.ferre@atmel.com>,
	Jamie Iles <jamie@jamieiles.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64324 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693Ab1HAOlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 10:41:47 -0400
Received: by wwe5 with SMTP id 5so5707285wwe.1
        for <netdev@vger.kernel.org>; Mon, 01 Aug 2011 07:41:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1312082850-24914-57-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 30, 2011 at 08:27:15PM -0700, Jeff Kirsher wrote:
> Move the Atmel driver into drivers/net/ethernet/cadence/ and
> make the necessary Kconfig and Makefile changes.
> 
> CC: Nicolas Ferre <nicolas.ferre@atmel.com>
> CC: Jamie Iles <jamie@jamieiles.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Looks good to me.

Acked-by: Jamie Iles <jamie@jamieiles.com>
