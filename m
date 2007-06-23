From: David Miller <davem@davemloft.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Sat, 23 Jun 2007 14:01:11 -0700 (PDT)
Message-ID: <20070623.140111.26947368.davem@davemloft.net>
References: <467D0C97.1000000@hartkopp.net>
	<467D178B.8080503@trash.net>
	<467D3891.4010906@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, j.hadi123@gmail.com, urs@isnogud.escape.de,
	tglx@linutronix.de, oliver.hartkopp@volkswagen.de,
	netdev@vger.kernel.org
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33329
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751409AbXFWVAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 17:00:52 -0400
In-Reply-To: <467D3891.4010906@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Sat, 23 Jun 2007 17:13:21 +0200

> Patrick McHardy wrote:
> > Oliver Hartkopp wrote:
> >   
> >> i was just looking through the mailings regarding your suggested changes
> >> (e.g. in VLAN, DUMMY and IFB) an none of them currently went into the
> >> kernel (..)
> >>     
> >
> >
> > They are all in the net-2.6.23 tree.
> >   
> 
> Ah, ok - that wasn't on my radar as i missed the mail from Dave to you
> at June 13th ...
> 
> @Dave: Please consider to schedule the PF_CAN stuff for inclusion into
> 2.6.23 also. Thx.

No.  Fix your code to use the correct interfaces and suggestions
from Patrick.
