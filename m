From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] netdevice.h: don't export MAX_HEADER to userspace
Date: Fri, 27 Jun 2008 19:55:04 -0700 (PDT)
Message-ID: <20080627.195504.33216915.davem@davemloft.net>
References: <20080623174906.GK4756@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39409
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752099AbYF1CzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 22:55:04 -0400
In-Reply-To: <20080623174906.GK4756@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>
Date: Mon, 23 Jun 2008 20:49:06 +0300

> Due to the CONFIG_'s the value is anyway not correct in userspace.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Fair enough, applied, thanks.
