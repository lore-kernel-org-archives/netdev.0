From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.27.18: bnx2/tg3: BUG: "scheduling while atomic" trying
 toifenslave a second interface to my bond
Date: Mon, 04 May 2009 12:06:51 -0700 (PDT)
Message-ID: <20090504.120651.32573620.davem@davemloft.net>
References: <1239657348.8944.529.camel@psmith-ubeta.netezza.com>
	<1241397581.6499.658.camel@homebase.localnet>
	<4086.1241463817@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul@mad-scientist.net, netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59766
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751515AbZEDTG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 15:06:56 -0400
In-Reply-To: <4086.1241463817@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Mon, 04 May 2009 12:03:37 -0700

> Paul Smith <paul@mad-scientist.net> wrote:
> 
>>Hi Jay/David/etc.;
>>
>>This patch is critical for me to properly use mode 6 (balance-alb)
>>bonding; I assume it will be needed for others as well.  I haven't
>>checked to see if it's still necessary in 2.6.29/2.6.30, but I didn't
>>notice it going into the latest 2.6.27.22, released today.
>>
>>Is this still unofficial?  Is there an official patch on the horizon?
> 
> 	David, please apply and queue for -stable:

Greg just posted that there will be no further 2.6.27.x -stable
releases after the one he just made.
