From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH kernel 2.6.34-rc3-git9] smc91c92_cs: define
 multicast_table as unsigned char
Date: Tue, 13 Apr 2010 03:09:54 -0700 (PDT)
Message-ID: <20100413.030954.171491080.davem@davemloft.net>
References: <20100328055537.13ef6c01.ken_kawasaki@spring.nifty.jp>
	<20100404061434.eb98ef3e.ken_kawasaki@spring.nifty.jp>
	<20100411075014.d3e80847.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49672
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752567Ab0DMKJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 06:09:51 -0400
In-Reply-To: <20100411075014.d3e80847.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Date: Sun, 11 Apr 2010 07:50:14 +0900

> 
> smc91c92_cs:
>   * define multicast_table as unsigned char
>   * remove unnecessary "#ifndef final_version"
> 
> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

It is clear there are not too many testers of multicast
with this driver :-)

Thanks for fixing this bug, patch applied.
