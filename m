From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/11][TG3]: Improve NVRAM sizing.
Date: Sat, 05 May 2007 11:51:15 -0700 (PDT)
Message-ID: <20070505.115115.77356582.davem@davemloft.net>
References: <1178326346.4859.18.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53287
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754675AbXEESv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2007 14:51:28 -0400
In-Reply-To: <1178326346.4859.18.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 04 May 2007 17:52:26 -0700

> [TG3]: Improve NVRAM sizing.
> 
> This patch changes the NVRAM sizing procedure so that the driver can
> take advantage of devices with 1:1 NVRAM strapping configurations.  This
> is useful in cases where the traditional NVRAM sizing method fails.  In
> the event that the flash size cannot be determined, the largest known
> NVRAM size is used.  The patch also removes support for 5755 NVRAM
> devices that are not supported by Broadcom and adds explicit sizing for
> this device.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
