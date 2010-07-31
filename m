From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: keep link (carrier) state up to date
Date: Fri, 30 Jul 2010 22:06:53 -0700 (PDT)
Message-ID: <20100730.220653.104061828.davem@davemloft.net>
References: <1280274823.23381.59.camel@voxel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nolan@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36284
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751143Ab0GaFGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jul 2010 01:06:36 -0400
In-Reply-To: <1280274823.23381.59.camel@voxel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nolan Leake <nolan@cumulusnetworks.com>
Date: Tue, 27 Jul 2010 16:53:43 -0700

> Currently, only ethtool can get accurate link state of a tap device.
> With this patch, IFF_RUNNING and IF_OPER_UP/DOWN are kept up to date as
> well.
> 
> Signed-off-by: Nolan Leake <nolan@cumulusnetworks.com>

Applied, thanks Nolan.
