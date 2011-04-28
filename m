From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 1/1] bna: Generic Netlink Interface to collect FW
 trace
Date: Thu, 28 Apr 2011 12:19:37 -0700 (PDT)
Message-ID: <20110428.121937.71128719.davem@davemloft.net>
References: <BANLkTinUsJ2foWKBVb_9nVFA2V_vKb11rA@mail.gmail.com>
	<20110426.191707.71110914.davem@davemloft.net>
	<BANLkTimOuF+HtLxsmTGVpC7ahU_NFy_L2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, rmody@brocade.com, netdev@vger.kernel.org,
	huangj@brocade.com, amathur@brocade.com, ddutt@brocade.com
To: debdut@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45518
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753380Ab1D1TUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 15:20:10 -0400
In-Reply-To: <BANLkTimOuF+HtLxsmTGVpC7ahU_NFy_L2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Debashis Dutt <debdut@gmail.com>
Date: Thu, 28 Apr 2011 10:51:27 -0700

> In that case should we use debugfs for collecting f/w trace,
> but use generic netlink for other h/w specific commands?

Sure.
