From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 04/12] l2tp: Add ppp device name to L2TP ppp session
 data
Date: Thu, 01 Apr 2010 02:04:02 -0700 (PDT)
Message-ID: <20100401.020402.148444988.davem@davemloft.net>
References: <4BB4490F.8090406@katalix.com>
	<20100401.003459.88028238.davem@davemloft.net>
	<4BB46084.5030105@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58381
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754281Ab0DAJEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 05:04:01 -0400
In-Reply-To: <4BB46084.5030105@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Thu, 01 Apr 2010 09:59:48 +0100

> The original /proc API was originally intended for debug, but users
> have been using it in hacky scripts instead of using proper socket
> interfaces to get the data they need. So I'm proposing to retain the
> existing proc file for compatibility but put other (new)
> driver-private debug info into debugfs.

Fair enough.
