From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add IDs for 3C905B-TX Fast Etherlink XL PCI
Date: Wed, 05 Aug 2009 20:24:32 -0700 (PDT)
Message-ID: <20090805.202432.19234688.davem@davemloft.net>
References: <1249481499-9560-1-git-send-email-pterjan@mandriva.com>
	<20090805144100.GA9346@skl-net.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pterjan@mandriva.com, netdev@vger.kernel.org
To: klassert@mathematik.tu-chemnitz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60290
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751162AbZHFDYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 23:24:23 -0400
In-Reply-To: <20090805144100.GA9346@skl-net.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Date: Wed, 5 Aug 2009 16:41:00 +0200

> On Wed, Aug 05, 2009 at 04:11:39PM +0200, Pascal Terjan wrote:
>> We found this old card which was not supported, and physically
>> looks similar to the other 3C905B we have (9055).
>> 
>> After adding the IDs it seems to work fine (MII report, dhcp, scp, ...)
> 
> The patch looks sane.
> Btw. you should add a Signed-off-by line to your patches.
> 
> Acked-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>

Applied, and yes please provide a proper Signed-off-by tag
in your commit message next time.
