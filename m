From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] enic: remove dead code
Date: Wed, 29 Sep 2010 19:57:20 -0700 (PDT)
Message-ID: <20100929.195720.241921649.davem@davemloft.net>
References: <20100929152930.520cc3b4@s6510>
	<212AA327A3557741A058E787E0618873042E0BC6@xmb-sjc-219.amer.cisco.com>
	<20100930114958.59c438d7@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vkolluri@cisco.com, netdev@vger.kernel.org, scofeldm@cisco.com,
	roprabhu@cisco.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38170
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751789Ab0I3C5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 22:57:00 -0400
In-Reply-To: <20100930114958.59c438d7@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 30 Sep 2010 11:49:58 +0900

> Ok, but Linux tree is not the repository for "possible future enhancements".
> Do it or remove it.

Agreed, remove it now and add it back when you submit the patches that
use the code.

The code is in the repository history so it's not like it's lost.
