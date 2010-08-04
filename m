From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] phy/marvell: add 88ec048 support
Date: Tue, 03 Aug 2010 19:36:17 -0700 (PDT)
Message-ID: <20100803.193617.39194871.davem@davemloft.net>
References: <1280883586-7727-1-git-send-email-cyril@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cyril@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54542
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757682Ab0HDCf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 22:35:59 -0400
In-Reply-To: <1280883586-7727-1-git-send-email-cyril@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cyril Chemparathy <cyril@ti.com>
Date: Tue,  3 Aug 2010 20:59:46 -0400

> Marvell 88ec048 is a derivative of its 88e1121r device.  From the programmer's
> perspective, the one major difference is the addition of an additional control
> bit in Page 2 Register 16 - used to control the padding of odd nibble
> preambles.
> 
> This patch adds support for this new device, while inheriting as much code as
> possible from the existing 88e1121r implementation.
> 
> Signed-off-by: Cyril Chemparathy <cyril@ti.com>

Applied, thanks a lot for fixing things up.
