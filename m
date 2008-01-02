From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] [IPV4] Remove three declarations of
 unimplemented methods and correct a typo in include/net/ip.h
Date: Tue, 01 Jan 2008 21:13:20 -0800 (PST)
Message-ID: <20080101.211320.160753170.davem@davemloft.net>
References: <eb3ff54b0801010030g36bef670n6150af5b683c4345@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39831
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750899AbYABFNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 00:13:20 -0500
In-Reply-To: <eb3ff54b0801010030g36bef670n6150af5b683c4345@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Tue, 1 Jan 2008 10:30:53 +0200

> These three declarations in include/net/ip.h are not implemented
> anywhere:
> ip_mc_dropsocket(), ip_mc_dropdevice() and ip_net_unreachable().
> 
> Also, correct a comment to be "Functions provided by ip_fragment.c"
> (instead of by ip_fragment.o) in consistency with the other comments in this
> header.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks.
