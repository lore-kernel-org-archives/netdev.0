From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][AX25] ax25_out: check skb for NULL in ax25_kick()
Date: Sun, 23 Mar 2008 22:03:20 -0700 (PDT)
Message-ID: <20080323.220320.254122034.davem@davemloft.net>
References: <025801c86ea3$75add3f0$453c822c@dg8ngn>
	<47D3A7AF.1030607@free.fr>
	<20080309143052.GA2749@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f6bvp@free.fr, jann@gmx.de, ralf@linux-mips.org,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40008
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751787AbYCXFDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 01:03:21 -0400
In-Reply-To: <20080309143052.GA2749@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 9 Mar 2008 15:30:52 +0100

> On Sun, Mar 09, 2008 at 10:02:39AM +0100, Pidoux wrote:
> ...
> >>> Subject: [AX25] ax25_out: check skb for NULL in ax25_kick()
> ...
> > Applied too and stable with kernel 2.6.24.3 since a week.
> 
> Good to know! It's merged to 2.6.25-rc3, but maybe recommending it for
> 2.6.24 wouldn't be a bad idea...

I've just queued this up for the next round of fixes I will
send to the -stable folks.
