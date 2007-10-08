From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4][TG3]: ASIC decoding and basic CPMU support.
Date: Sun, 07 Oct 2007 23:28:23 -0700 (PDT)
Message-ID: <20071007.232823.85391436.davem@davemloft.net>
References: <1191641858.17453.7.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43367
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751503AbXJHG2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 02:28:24 -0400
In-Reply-To: <1191641858.17453.7.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 05 Oct 2007 20:37:38 -0700

> [TG3]: ASIC decoding and basic CPMU support.
> 
> Newer products change the way the ASIC revision is obtained.  This patch
> implements how the driver will extract the revision number.
> 
> This patch also adds preliminary CPMU support.  CPMU stands for Central
> Power Management Unit.  The CPMU's role is to put the chip into lower
> power states when the operating conditions allow it.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
