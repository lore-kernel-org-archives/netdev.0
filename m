From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/12] IPv6 addrconf changes
Date: Wed, 03 Mar 2010 01:16:05 -0800 (PST)
Message-ID: <20100303.011605.225992271.davem@davemloft.net>
References: <20100302233243.259794027@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35712
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751405Ab0CCJPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 04:15:49 -0500
In-Reply-To: <20100302233243.259794027@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 02 Mar 2010 15:32:43 -0800

> This set includes a mixed bag of changes all related to
> IPv6 address configuration:  bugfixes (1-3,8), changes to use
> list interface (4-5,8), RCU (6), cosmetic cleanups (9-10,12) and
> minor improvments (7,11).

Unless you split out the change that are not bug fixes, this
will have to wait until the next merge window.

As I very clearly stated the other day I'm really not taking
anything other than bug fixes after Linus takes in my pull
request, which he did today.
