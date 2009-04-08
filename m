From: David Miller <davem@davemloft.net>
Subject: Re: [patch] locking typo in xfrm_state.c
Date: Wed, 08 Apr 2009 04:15:59 -0700 (PDT)
Message-ID: <20090408.041559.245922838.davem@davemloft.net>
References: <alpine.DEB.2.00.0904081345430.30705@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46445
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752996AbZDHLQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 07:16:09 -0400
In-Reply-To: <alpine.DEB.2.00.0904081345430.30705@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Wed, 8 Apr 2009 13:45:48 +0300 (EAT)

> I'm not sure who to send this patch to.
> 
> There is a double lock instead of an unlock.
> 
> Found by smatch (http://repo.or.cz/w/smatch.git).  Compile tested.

Already fixed in mainline and -stable.
