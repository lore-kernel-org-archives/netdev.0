From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 3/3]ipv6:fix the outgoing interface selection
 order in udpv6_sendmsg()
Date: Tue, 16 Dec 2008 02:09:28 -0800 (PST)
Message-ID: <20081216.020928.194521279.davem@davemloft.net>
References: <493F63E1.3030800@cn.fujitsu.com>
	<20081210.011514.120756807.davem@davemloft.net>
	<493F8EBA.7070907@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: remi.denis-courmont@nokia.com, netdev@vger.kernel.org
To: yanghy@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47384
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752463AbYLPKJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 05:09:27 -0500
In-Reply-To: <493F8EBA.7070907@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Hongyang <yanghy@cn.fujitsu.com>
Date: Wed, 10 Dec 2008 17:41:14 +0800

> Thanks for your comment,here is the updated patch:
 ...
> Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

Applied.
