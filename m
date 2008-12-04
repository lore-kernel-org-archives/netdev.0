From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next]mptlan: Kill directly reference of netdev->priv
Date: Wed, 03 Dec 2008 21:13:43 -0800 (PST)
Message-ID: <20081203.211343.172131838.davem@davemloft.net>
References: <493538F5.3000500@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39543
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751526AbYLDFNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 00:13:43 -0500
In-Reply-To: <493538F5.3000500@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Tue, 02 Dec 2008 21:32:37 +0800

> Simply replace netdev->priv with netdev_priv().
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied.
