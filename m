From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mv643xx_eth: Remove a stale PPC_MULTIPLATFORM
Date: Sun, 17 May 2009 13:59:21 -0700 (PDT)
Message-ID: <20090517.135921.196120384.davem@davemloft.net>
References: <1242230698-15684-1-git-send-email-Emilian.Medve@Freescale.com>
	<20090513161327.GI9359@server.marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Emilian.Medve@Freescale.com, netdev@vger.kernel.org
To: buytenh@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37050
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752037AbZEQU7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 16:59:24 -0400
In-Reply-To: <20090513161327.GI9359@server.marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@marvell.com>
Date: Wed, 13 May 2009 09:13:27 -0700

> On Wed, May 13, 2009 at 09:04:58AM -0700, Emil Medve wrote:
> 
>> PPC_MULTIPLATFORM was killed in commit 28794d3 but this stale occurrence was
>> hiding the mv643xx_eth driver in some cases (e.g. Pegasos II)
>> 
>> Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>
> 
> Acked-by: Lennert Buytenhek <buytenh@marvell.com>

Applied.
