From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] staging-slicoss: Kill directly reference of
 netdev->priv
Date: Sat, 06 Dec 2008 23:59:50 -0800 (PST)
Message-ID: <20081206.235950.120548600.davem@davemloft.net>
References: <493946EB.7000308@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gregkh@suse.de
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59422
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752825AbYLGH7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2008 02:59:50 -0500
In-Reply-To: <493946EB.7000308@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 05 Dec 2008 23:21:15 +0800

> Simply replace netdev->priv with netdev_priv().
> 
> Compile test only.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Also applied, thanks Wang.

Wang, how much more of this stuff do you estimate we still
have to fix up before we can really kill off ->priv?

Just curious...
