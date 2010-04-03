From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH kernel 2.6.34-rc3] smc91c92_cs: fix the problem of
 "Unable to find hardware address"
Date: Sat, 03 Apr 2010 15:07:21 -0700 (PDT)
Message-ID: <20100403.150721.247299399.davem@davemloft.net>
References: <20100228083420.9ca8e285.ken_kawasaki@spring.nifty.jp>
	<20100328055537.13ef6c01.ken_kawasaki@spring.nifty.jp>
	<20100404061434.eb98ef3e.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60760
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754194Ab0DCWHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Apr 2010 18:07:19 -0400
In-Reply-To: <20100404061434.eb98ef3e.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Date: Sun, 4 Apr 2010 06:14:34 +0900

> 
> smc91c92_cs:
>  *cvt_ascii_address returns 0, if success.
>  *call free_netdev, if we can't find hardware address.
> 
> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

Applied, thanks.
