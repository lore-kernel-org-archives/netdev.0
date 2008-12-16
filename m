From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 2/3]ipv6:fix the return interface index when get
 it while no message is received
Date: Tue, 16 Dec 2008 02:09:09 -0800 (PST)
Message-ID: <20081216.020909.156019033.davem@davemloft.net>
References: <493E19FC.1080609@cn.fujitsu.com>
	<49461DF2.8030502@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yanghy@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47382
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752295AbYLPKJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 05:09:08 -0500
In-Reply-To: <49461DF2.8030502@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Hongyang <yanghy@cn.fujitsu.com>
Date: Mon, 15 Dec 2008 17:05:54 +0800

> Updated patch:
> 
> When get receiving interface index while no message is received,
> the the value seted with setsockopt() should be returned.
 ...
> Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

Applied.
