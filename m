From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xen-netback: Fix slot estimation
Date: Fri, 06 Jun 2014 13:06:43 -0700 (PDT)
Message-ID: <20140606.130643.82505365823461689.davem@davemloft.net>
References: <1401802336-25182-1-git-send-email-zoltan.kiss@citrix.com>
	<20140605.150209.365488173138758921.davem@davemloft.net>
	<539195FD.6080606@schaman.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, ian.campbell@citrix.com,
	wei.liu2@citrix.com, paul.durrant@citrix.com, linux@eikelenboom.it,
	netdev@vger.kernel.org, david.vrabel@citrix.com
To: zoltan.kiss@schaman.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59895 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620AbaFFUGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 16:06:44 -0400
In-Reply-To: <539195FD.6080606@schaman.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zoltan Kiss <zoltan.kiss@schaman.hu>
Date: Fri, 06 Jun 2014 11:20:45 +0100

> I haven't wrote it explicitly, but my other patch "xen-netback: Fix
> handling of skbs requiring too many slots" supersedes this one.

Right, I figured this out after reading these threads over again.
