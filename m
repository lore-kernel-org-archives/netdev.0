From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] staging-winbond: Kill directly reference of
 netdev->priv
Date: Mon, 08 Dec 2008 01:13:38 -0800 (PST)
Message-ID: <20081208.011338.170851240.davem@davemloft.net>
References: <493CB1A2.7080005@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52527
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751050AbYLHJNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 04:13:38 -0500
In-Reply-To: <493CB1A2.7080005@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Mon, 08 Dec 2008 13:33:22 +0800

> This driver is not yet finished.
> At this time, we don't know how netdev be created and how
> private data be allocated.
> So, simply use netdev_priv() now and leave some temp comment.
> 
> Compile test only.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied, thanks.
