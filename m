From: David Miller <davem@davemloft.net>
Subject: Re: Gianfar: RX Recycle skb->len error
Date: Tue, 23 Mar 2010 13:00:07 -0700 (PDT)
Message-ID: <20100323.130007.221580663.davem@davemloft.net>
References: <A6A1774AFD79E346AE6D49A33CB294530DC19F18@EX-BE-017-SFO.shared.themessagecenter.com>
	<20100322.203053.37576243.davem@davemloft.net>
	<A6A1774AFD79E346AE6D49A33CB294530DC19F4A@EX-BE-017-SFO.shared.themessagecenter.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avorontsov@ru.mvista.com, netdev@vger.kernel.org,
	Sandeep.Kumar@freescale.com, kumar.gala@freescale.com
To: ben@bigfootnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47430
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753815Ab0CWT7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 15:59:44 -0400
In-Reply-To: <A6A1774AFD79E346AE6D49A33CB294530DC19F4A@EX-BE-017-SFO.shared.themessagecenter.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ben Menchaca (ben@bigfootnetworks.com)" <ben@bigfootnetworks.com>
Date: Tue, 23 Mar 2010 07:16:58 -0700

>> There's no need to make this so complicated.  Just remember the
>> value and then refer to it later, when needed.
>
> Thanks for the sanity adjustment!  As suggested, then...hope to hear
> from FS soon.

Let's get this tested and with a proper commit message and
signoff so it can get applied.

Thanks!
