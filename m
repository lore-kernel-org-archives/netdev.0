From: David Miller <davem@davemloft.net>
Subject: Re: can we reuse an skb
Date: Sat, 20 Jun 2009 22:49:12 -0700 (PDT)
Message-ID: <20090620.224912.217086631.davem@davemloft.net>
References: <4A3BC326.4090203@hp.com>
	<20090619.162957.156347025.davem@davemloft.net>
	<1f808b4a0906202241l1d74364ft52d99ecb6b0274f5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, radhamohan_ch@yahoo.com, netdev@vger.kernel.org
To: peterchacko35@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32788
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751472AbZFUFtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2009 01:49:09 -0400
In-Reply-To: <1f808b4a0906202241l1d74364ft52d99ecb6b0274f5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Chacko <peterchacko35@gmail.com>
Date: Sun, 21 Jun 2009 11:11:16 +0530

> Here i am considering a special case where Linux stack is not used in
> a host environment. Its dedicated packet processor. Application data
> is not expected. (discarded if thats the case).

Linux is a general purpose operating system.

You can modify it for your own needs, locally, however you want.  But
upstream, we have to consider all use cases, not just your's.
