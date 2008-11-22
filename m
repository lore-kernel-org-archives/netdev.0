From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 05/10] tg3: Extract FW ver from alt NVRAM formats
Date: Fri, 21 Nov 2008 17:19:55 -0800 (PST)
Message-ID: <20081121.171955.102948720.davem@davemloft.net>
References: <1227295576.5620@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57970
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752250AbYKVBT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 20:19:56 -0500
In-Reply-To: <1227295576.5620@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 21 Nov 2008 11:01:34 -0800

> This patch extracts the bootcode firmware version from the alternate
> selfboot patch NVRAM format.  This format is used on the 5784, 5761 and
> some newer devices.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
