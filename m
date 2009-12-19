From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] broadcom: bcm54xx_shadow_read() errors ignored in
 bcm54xx_adjust_rxrefclk()
Date: Fri, 18 Dec 2009 20:16:20 -0800 (PST)
Message-ID: <20091218.201620.28810836.davem@davemloft.net>
References: <4B28DA62.40909@gmail.com>
	<20091218014138.GA22080@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36589
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756027AbZLSEQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 23:16:18 -0500
In-Reply-To: <20091218014138.GA22080@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Thu, 17 Dec 2009 17:41:39 -0800

> On Wed, Dec 16, 2009 at 05:02:26AM -0800, Roel Kluin wrote:
>> If not signed read errors are ignored.
>> 
>> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> 
> Acked-by: Matt Carlson <mcarlson@broadcom.com>

Applied, thanks.
